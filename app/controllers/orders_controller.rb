class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :set_order, only: [:show, :pay, :success, :failure]
  before_action :ensure_order_belongs_to_user, only: [:show, :pay, :success, :failure]
  skip_before_action :verify_authenticity_token, only: [:webhook], raise: false

  def index
    # Show only current user's orders
    @orders = current_user.orders.order(created_at: :desc).page(params[:page])
  end


  def create
    # Create new order from hosting plan purchase
    @order = current_user.orders.build(order_params)
    @order.status = 'pending'
    
    if @order.save
      # Immediately redirect to payment
      stripe_service = StripePaymentService.new(@order, request)
      result = stripe_service.call
      
      if result[:success]
        @checkout_session = result[:checkout_session]
        redirect_to @checkout_session.url, allow_other_host: true
      else
        flash[:alert] = "Payment initialization failed: #{result[:error]}"
        redirect_to hosting_plans_path
      end
    else
      flash[:alert] = "Order creation failed: #{@order.errors.full_messages.join(', ')}"
      redirect_to hosting_plans_path
    end
  end

  def show
    # Show order details and payment button
    # Payment will be initiated from this page
  end

  def pay
    # Initialize payment for existing order
    stripe_service = StripePaymentService.new(@order, request)
    result = stripe_service.call

    if result[:success]
      @checkout_session = result[:checkout_session]
      # Redirect to Stripe Checkout
      redirect_to @checkout_session.url, allow_other_host: true
    else
      flash[:alert] = "Payment initialization failed: #{result[:error]}"
      redirect_to @order
    end
  end

  def success
    # In development mode, check and update order status from Stripe
    # since webhooks might not be properly configured
    if Rails.env.development? && @order.processing?
      update_order_status_from_stripe
    end

    # Allow access regardless of status for display purposes
    # The view will show appropriate content based on order status
  end

  def failure
    # Allow access regardless of status for display purposes
    # The view will show appropriate content based on order status
  end

  # Webhook endpoint for Stripe
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.config.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      StripePaymentService.process_webhook_event(event)
      render json: { status: 'success' }
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
  
  def ensure_order_belongs_to_user
    unless @order.user == current_user
      flash[:alert] = "You don't have permission to access this order."
      redirect_to orders_path
    end
  end
  
  def order_params
    params.permit(:customer_name, :customer_email, :product_name, :amount, :currency, :hosting_plan_id)
  end


  # Update order status by checking Stripe directly (for development)
  def update_order_status_from_stripe
    return unless @order&.stripe_payment_intent_id&.present?

    begin
      # Check if it's a checkout session ID
      if @order.stripe_payment_intent_id.start_with?('cs_')
        session = Stripe::Checkout::Session.retrieve(@order.stripe_payment_intent_id)

        case session.payment_status
        when 'paid'
          @order.mark_as_paid!
          Rails.logger.info "Development: Updated order #{@order.id} to paid status"
        when 'unpaid'
          Rails.logger.info "Development: Order #{@order.id} still unpaid in Stripe"
        end
      else
        # If it's a payment intent ID
        payment_intent = Stripe::PaymentIntent.retrieve(@order.stripe_payment_intent_id)

        case payment_intent.status
        when 'succeeded'
          @order.mark_as_paid!
          Rails.logger.info "Development: Updated order #{@order.id} to paid status"
        when 'requires_payment_method', 'requires_confirmation'
          Rails.logger.info "Development: Order #{@order.id} still requires payment"
        end
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Development: Failed to check Stripe status for order #{@order.id}: #{e.message}"
    rescue => e
      Rails.logger.error "Development: Error updating order status: #{e.message}"
    end
  end
end
