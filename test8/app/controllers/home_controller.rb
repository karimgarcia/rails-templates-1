  # frozen_string_literal: true
  class HomeController < ShopifyApp::AuthenticatedController
    layout "application"
    def home
      @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
      @webhooks = ShopifyAPI::Webhook.find(:all)
    end

    def index
      if session["shopify"]
        @shop = Shop.find(session["shopify"])
      else
        redirect_to shopify_app_url
      end

      @plan = ShopifyAPI::RecurringApplicationCharge.current

      if @plan
        redirect_to home_url
      end

    end
  end



