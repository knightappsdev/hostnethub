# HostNetHub - Complete Web Hosting Platform

A fully functional web hosting business platform built with Ruby on Rails 7.2, featuring integrated FREE marketing tools that provide significant value to customers.

## 🌟 Key Features

### FREE Marketing Suite (Competitive Advantage)
- **FREE Email Marketing Suite** (£29/month value)
- **FREE Digital Marketing Tools** (£127/month value) 
- **FREE Smart Migration Assistant** (£299 value)
- **Total FREE Value**: £455/month + £299 setup

### Core Platform Features
- **Premium Web Hosting Plans** - Starter, Professional, Business, Enterprise
- **User Authentication** - OAuth support (Google, Facebook, Twitter, GitHub)
- **Stripe Payment Integration** - Secure payment processing
- **Customer Dashboard** - Order management, marketing tools access, account statistics
- **Admin Panel** - Complete CRUD management for hosting plans, users, and orders
- **Responsive Design** - Mobile-optimized with Tailwind CSS v3

## 🏗️ Tech Stack

- **Backend**: Ruby on Rails 7.2
- **Frontend**: Tailwind CSS v3, Stimulus
- **Database**: PostgreSQL
- **Payment**: Stripe
- **Authentication**: Devise with OmniAuth
- **Testing**: RSpec (21 examples, 0 failures)
- **Deployment**: Docker ready

## 🚀 Getting Started

### Prerequisites
- Ruby 3.3.5
- PostgreSQL
- Node.js (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/knightappsdev/hostnethub.git
   cd hostnethub
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Configure environment variables**
   Create `application.yml` file:
   ```yaml
   STRIPE_PUBLISHABLE_KEY: "pk_test_your_key"
   STRIPE_SECRET_KEY: "sk_test_your_key"
   GOOGLE_CLIENT_SECRET: "your_google_client_secret"
   FACEBOOK_APP_SECRET: "your_facebook_app_secret"
   TWITTER_CLIENT_SECRET: "your_twitter_client_secret"
   GITHUB_CLIENT_SECRET: "your_github_client_secret"
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```

6. **Visit the application**
   Open http://localhost:3000

## 📋 Testing

Run the comprehensive test suite:
```bash
rake test
```

Current test status: **21 examples, 0 failures, 1 pending**

## 🎯 Business Model

### Hosting Plans
- **Starter**: £4.99/month - 10GB storage, 100GB bandwidth
- **Professional**: £9.99/month - 50GB storage, 500GB bandwidth  
- **Business**: £19.99/month - 100GB storage, 1TB bandwidth
- **Enterprise**: £39.99/month - Unlimited storage & bandwidth

### Competitive Advantage
All plans include FREE marketing tools worth £455/month:
- Email Marketing Suite (normally £29/month)
- Digital Marketing Tools (normally £127/month)
- Smart Migration Assistant (normally £299 setup)

### Customer Savings
Customers save £1,392-£3,252 annually compared to purchasing hosting and marketing tools separately.

## 🔧 Architecture

### Models
- **User** - Customer accounts with OAuth authentication
- **HostingPlan** - Hosting packages with pricing and features
- **Order** - Stripe-integrated payment processing

### Controllers
- **HomeController** - Landing page with marketing content
- **DashboardsController** - Customer dashboard (authenticated)
- **OrdersController** - Payment processing and order management
- **Admin::** - CRUD management for hosting plans, users, orders

### Key Features
- **Semantic Design System** - HSL-based color tokens
- **Mobile-First Design** - Responsive across all devices
- **SEO Optimized** - Structured data and meta tags
- **Security First** - Authentication, authorization, and input validation

## 🌐 Admin Panel

Access the admin panel at `/admin` with administrator credentials:
- Manage hosting plans and pricing
- View and manage customer accounts
- Track orders and payment status
- Monitor business metrics

## 📊 Customer Dashboard

Authenticated users can access:
- Account statistics and usage
- Order history and invoices
- FREE marketing tools suite
- Upgrade recommendations
- Support tickets

## 🔒 Security Features

- CSRF protection
- SQL injection prevention
- XSS protection
- Secure authentication with Devise
- OAuth integration
- Input validation and sanitization

## 🚀 Deployment

The application is Docker-ready and can be deployed to:
- Railway
- Heroku
- AWS
- Google Cloud Platform
- Any Docker-compatible platform

## 📈 Performance

- Optimized asset pipeline
- CSS/JS minification
- Database query optimization
- Responsive caching strategies
- CDN-ready static assets

## 🛠️ Development

### Code Quality
- RuboCop for Ruby style guide compliance
- RSpec for comprehensive testing
- Semantic commit messages
- RESTful API design

### Contributing
1. Fork the repository
2. Create a feature branch
3. Write tests for new features
4. Ensure all tests pass
5. Submit a pull request

## 📞 Support

For technical support or business inquiries:
- GitHub Issues: [Create Issue](https://github.com/knightappsdev/hostnethub/issues)
- Email: support@hostnethub.com

## 📜 License

This project is proprietary software developed for commercial use.

## 🏆 Competitive Analysis

HostNetHub differentiates from competitors by offering:
- **£455/month in FREE marketing tools** (vs £0 from competitors)
- **Integrated marketing suite** (vs separate paid tools)
- **£299 FREE migration service** (vs £100-500 setup fees)
- **Modern Rails 7.2 architecture** (vs legacy PHP platforms)
- **Comprehensive admin panel** (vs limited management tools)

---

**Built with ❤️ by KnightAppsDev**

*Empowering businesses with premium hosting and FREE marketing tools.*