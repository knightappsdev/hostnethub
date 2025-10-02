class Admin::DealsController < Admin::BaseController
  before_action :set_deal, only: [:show, :edit, :update, :destroy]

  def index
    @deals = Deal.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @deal = Deal.new
  end

  def create
    @deal = Deal.new(deal_params)

    if @deal.save
      redirect_to admin_deal_path(@deal), notice: 'Deal was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @deal.update(deal_params)
      redirect_to admin_deal_path(@deal), notice: 'Deal was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deal.destroy
    redirect_to admin_deals_path, notice: 'Deal was successfully deleted.'
  end

  private

  def set_deal
    @deal = Deal.find(params[:id])
  end

  def deal_params
    params.require(:deal).permit(:name, :description, :amount, :stage, :probability, :expected_close_date, :actual_close_date, :contact_id, :user_id, :assigned_to_id)
  end
end
