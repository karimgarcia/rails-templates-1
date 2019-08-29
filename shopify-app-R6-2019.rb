run 'pgrep spring | xargs kill -9'

p "Name of the app (must be the same of the folder)"
APP_NAME = STDIN.gets.downcase.chomp

p "enter my APIKEY: "
p "(if you don't, create a new app in your partner shoify account)"


API_KEY = STDIN.gets.downcase.chomp

p "enter my SECRETKEY: "
SECRET_KEY = STDIN.gets.downcase.chomp

p "do you want charge Recurring Charge ? (y/n): "
RECURRING = (STDIN.gets.downcase.chomp == 'y')

if RECURRING
  p "How many days of free trial? (0 for no): "
  FREETRIAL = STDIN.gets.downcase.chomp
  p "How much it cost by month: "
  RECURRINGPRICE = STDIN.gets.downcase.chomp
else
  p "do you want a One time charge ? (y/n): "
  ONETIMECHARGE = (STDIN.gets.downcase.chomp == 'y')
  p "How much it cost ?: "
  ONETIMEPRICE = STDIN.gets.downcase.chomp
end

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

#{"gem 'bootsnap', require: false" if Rails.version >= "5.2"}
gem 'jbuilder', '~> 2.0'
gem 'pg', '~> 0.21'
gem 'puma'
gem 'rails', '#{Rails.version}'
gem 'redis'

# gem 'bootstrap', '~> 4.3.1'
# gem 'bootstrap-sass', '~> 3.3'

gem 'autoprefixer-rails'
gem 'font-awesome-sass', '~> 5.6.1'
gem 'sassc-rails'
gem 'simple_form'
gem 'uglifier'
gem 'webpacker'
gem 'shopify_app'
gem 'rack-cors', require: 'rack/cors'


group :development do
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'dotenv-rails'
end
RUBY

# Ruby version
########################################
file '.ruby-version', RUBY_VERSION

# Procfile
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

# Assets
########################################
run 'rm -rf app/assets/stylesheets'
run 'rm -rf vendor'
run 'curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip'
run 'unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets'
inject_into_file 'app/assets/stylesheets/config/_bootstrap_variables.scss', before: '// Override other variables below!' do
"
// Patch to make simple_form compatible with bootstrap 3
.invalid-feedback {
  display: none;
  width: 100%;
  margin-top: 0.25rem;
  font-size: 80%;
  color: $red;
}

.was-validated .form-control:invalid,
.form-control.is-invalid,
.was-validated .custom-select:invalid,
.custom-select.is-invalid {
  border-color: $red;
}

.was-validated .form-control:invalid ~ .invalid-feedback,
.was-validated .form-control:invalid ~ .invalid-tooltip,
.form-control.is-invalid ~ .invalid-feedback,
.form-control.is-invalid ~ .invalid-tooltip,
.was-validated .custom-select:invalid ~ .invalid-feedback,
.was-validated .custom-select:invalid ~ .invalid-tooltip,
.custom-select.is-invalid ~ .invalid-feedback,
.custom-select.is-invalid ~ .invalid-tooltip {
  display: block;
}

"
end

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require rails-ujs
//= require_tree .
JS

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>TODO</title>
    <%= csrf_meta_tags %>
    <%= action_cable_meta_tag %>
    <%= stylesheet_link_tag 'application', media: 'all' %>
    <link
      rel="stylesheet"
      href="https://sdks.shopifycdn.com/polaris/3.17.0/polaris.min.css"
    />
    <%#= stylesheet_pack_tag 'application', media: 'all' %> <!-- Uncomment if you import CSS in app/javascript/packs/application.js -->
  </head>
  <body>
    <%= render 'shared/navbar' %>
    <%= render 'shared/flashes' %>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
    <%= javascript_pack_tag 'application' %>
  </body>
</html>
HTML


file 'app/views/shared/_flashes.html.erb', <<-HTML
<% if notice %>
  <div class="alert alert-info alert-dismissible" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <%= notice %>
  </div>
<% end %>
<% if alert %>
  <div class="alert alert-warning alert-dismissible" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <%= alert %>
  </div>
<% end %>
HTML

run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/logo.png > app/assets/images/logo.png'

file 'app/views/shared/_navbar.html.erb', <<-HTML
  <div class="navbar navbar-expand-sm navbar-light navbar-lewagon">
    <%= link_to "#", class: "navbar-brand" do %>
      <%= image_tag "https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/logo.png" %>
      <% end %>

    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>


    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav mr-auto">
          <li class="nav-item">
            <%= link_to "Logout", "/logout", class: "nav-link" %>
          </li>
      </ul>
    </div>
  </div>

HTML

# README
########################################
markdown_file_content = <<-MARKDOWN
Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file 'README.md', markdown_file_content, force: true

# Generators
########################################
generators = <<-RUBY
config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework  :test_unit, fixture: false
    end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command 'db:drop db:create db:migrate'
  generate('simple_form:install', '--bootstrap')
  generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')

  # Routes
  ########################################
  route "root to: 'pages#home'"
  run 'rm config/routes.rb'
  file 'config/routes.rb', <<-RUBY
    Rails.application.routes.draw do
      root :to => 'home#index'
      mount ShopifyApp::Engine, at: '/'
      # root to: 'pages#home'
      namespace :api, defaults: { format: :json } do
        namespace :v1 do
          get 'products', to: 'products#index'
        end
      end
      # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    end



  RUBY

  if RECURRING
    run 'rm config/routes.rb'
    file 'config/routes.rb', <<-RUBY
      Rails.application.routes.draw do
        root :to => 'home#index'
        get :home, to: 'home#home'
        mount ShopifyApp::Engine, at: '/'
        # root to: 'pages#home'
        namespace :api, defaults: { format: :json } do
         namespace :v1 do
           get 'products', to: 'products#index'
         end
        end
        # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
        resource :recurring_application_charge, only: [:show, :create_free_plan, :create_silver_plan, :create_gold_plan, :destroy] do
          collection do
            get :create_free_plan, to: 'recurring_application_charges#create_free_plan'
            get :create_silver_plan, to: 'recurring_application_charges#create_silver_plan'
            get :create_gold_plan, to: 'recurring_application_charges#create_gold_plan'
            get :show, to: 'recurring_application_charges#show'
            get :callback
            post :customize
          end
        end
      end




    RUBY
  end

  # Git ignore
  ########################################
  run 'rm .gitignore'
  file '.gitignore', <<-TXT
.bundle
log/*.log
tmp/**/*
tmp/*
!log/.keep
!tmp/.keep
*.swp
.DS_Store
public/assets
public/packs
public/packs-test
node_modules
development_env.yml
production_env.yml
yarn-error.log
.byebug_history
.env*
TXT

  # Credentials
  ########################################
  file 'config/development_env.yml', <<-RUBY
  ROOT_URL: 'https://localhost:3000'
  APP_NAME: #{APP_NAME}
  SHOPIFY_CLIENT_API_KEY: #{API_KEY}
  SHOPIFY_CLIENT_API_SECRET: #{SECRET_KEY}

RUBY

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ShopifyApp::AuthenticatedController
  protect_from_forgery with: :exception
  include Response
  # before_action :authenticate_user!
end
RUBY

  # Pages Controller
  ########################################
  run 'rm app/controllers/pages_controller.rb'
  file 'app/controllers/pages_controller.rb', <<-RUBY
class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:home]

  def home
  end
end
RUBY

# Environments
########################################
environment 'config.action_mailer.default_url_options = { host: ENV["ROOT_URL"] }', env: 'development'
environment 'config.action_mailer.default_url_options = { host: ENV["ROOT_URL"] }', env: 'production'


  # Webpacker / Yarn
  ########################################
  run 'rm app/javascript/packs/application.js'
  run 'yarn add popper.js jquery bootstrap'
  run 'yarn add @shopify/polaris'
  file 'app/javascript/packs/application.js', <<-JS
import "bootstrap";
JS


generate('shopify_app:install', '--api_key #{API_KEY}', '--secret #{SECRET_KEY}')
generate('shopify_app:shop_model')
generate('shopify_app:home_controller')
# generate('shopify_app:app_proxy_controller')
generate('shopify_app:controllers')
rails_command 'db:migrate'
  run 'rm config/initializers/shopify_app.rb'
  file 'config/initializers/shopify_app.rb', <<-RUBY

ShopifyApp.configure do |config|
  config.application_name = ENV["APP_NAME"]
  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.scope = "read_products, write_products"
                  #"read_content, write_content, read_themes, write_themes, read_products, write_products, read_product_listings, read_customers, write_customers, read_orders, write_orders, read_orders, write_orders, read_all_orders,read_draft_orders, write_draft_orders,read_inventory, write_inventory,read_locations, read_script_tags, write_script_tags, read_fulfillments, write_fulfillments,read_shipping, write_shipping,read_analytics,read_users, write_users,read_checkouts, write_checkouts,read_reports, write_reports, read_price_rules, write_price_rules,read_marketing_events, write_marketing_events,read_resource_feedbacks, write_resource_feedbacks,read_shopify_payments_payouts" # Consult this page for more scope options:
                                  # https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
  config.embedded_app = false
  config.after_authenticate_job = false
  config.session_repository = Shop
  config.api_version = '2019-04'
  # config.root_url = '/nested'
  # webhook
  # config.webhooks = [
  #   {topic: 'products/create', address: "ENV['ROOT_URL']/webhooks/products_update"}
  # ]
  config.scripttags = [
      {event:'onload', src: 'https://my-shopifyapp.herokuapp.com/fancy.js'}
    ]
end
RUBY

    # Shop model
    ########################################
    run 'rm app/models/shop.rb'
    file 'app/models/shop.rb', <<-RUBY
    class Shop < ActiveRecord::Base
      include ShopifyApp::SessionStorage

      def connect_to_store
        session = ShopifyAPI::Session.new({domain: self.shopify_domain, token: self.shopify_token, api_version: api_version})
        session.valid?
        ShopifyAPI::Base.activate_session(session)
      end

      def api_version
        ShopifyApp.configuration.api_version
      end
    end



  RUBY

    # RESPONSE.RB
    ########################################
    file 'app/controllers/concerns/response.rb', <<-RUBY
    module Response
      def json_response(object, status = :ok)
        render json: object, status: status
      end
    end


  RUBY


 # API/V1/PRODUCT CONTROLLER
  ########################################
  file 'app/controllers/api/v1/products_controller.rb', <<-RUBY
  module Api
    module V1
      class ProductsController < ApplicationController
      # class ProductsController < ShopifyApp::AuthenticatedController
        protect_from_forgery with: :null_session
        # before_action :set_todo
        # before_action :authenticate_user!
        before_action :set_session
        # before_action :set_todo_item
        # before_action :set_todo_item_comment, only: %i[show update destroy]
        # GET /todos/:todo_id/items/:item_id/comments
        def index
          if params[:title] != 'undefined'
            @products = ShopifyAPI::Product.find(:all, params: {limit: 10, page: params[:page], title: params[:title]})
          else
            @products = ShopifyAPI::Product.find(:all, params: {limit: 10, page: params[:page]})
          end
          json_response({products: @products})
        end
        # # GET /todos/:todo_id/items/:item_id/comments/:id
        # def show
        #   json_response(@comment)
        # end
        # # POST /todos/:todo_id/items/:item_id/comments
        # def create
        #   @comment = @item.comments
        #   authorize(@comment)
        #   @comment.create!(comment_params)
        #   json_response(@comment, :created)
        # end
        # # PUT /todos/:todo_id/items/:id
        # def update
        #   @comment.update(comment_params)
        #   authorize(@comment)
        #   head :no_content
        # end
        # # DELETE /todos/:todo_id/items/:id
        # def destroy
        #   @comment.destroy
        #   authorize(@comment)
        #   head :no_content
        # end
        private
        def set_session
          @shop = Shop.where(shopify_domain: session['shopify_domain']).first
          @shop.connect_to_store
        end
      end
    end
  end
RUBY

  # Application Job
  ########################################
  run 'rm app/controllers/home_controller.rb'
  file 'app/controllers/home_controller.rb', <<-RUBY
  # frozen_string_literal: true
  class HomeController < ShopifyApp::AuthenticatedController
    layout "application"
    def index
      @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
      @webhooks = ShopifyAPI::Webhook.find(:all)
    end
  end

RUBY
  # Application Job
  ########################################
  run 'rm app/jobs/application_job.rb'
  file 'app/jobs/application_job.rb', <<-RUBY
  class ApplicationJob < ActiveJob::Base
    def session_api(shop_domain)
      @shop = Shop.where(shopify_domain: shop_domain).first
      @shop.connect_to_store
    end
  end

RUBY
   # Application.rb
  ########################################
  run 'rm config/application.rb'
  file 'config/application.rb', <<-RUBY
  require_relative 'boot'

  require "rails"
  # Pick the frameworks you want:
  require "active_model/railtie"
  require "active_job/railtie"
  require "active_record/railtie"
  require "active_storage/engine"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "action_view/railtie"
  require "action_cable/engine"
  require "sprockets/railtie"
  # require "rails/test_unit/railtie"

  # Require the gems listed in Gemfile, including any gems
  # you've limited to :test, :development, or :production.
  Bundler.require(*Rails.groups)

  module Test1
    class Application < Rails::Application
      config.generators do |generate|
            generate.assets false
            generate.helper false
            generate.test_framework  :test_unit, fixture: false
          end
      # Initialize configuration defaults for originally generated Rails version.
      config.load_defaults 5.2

      # allow public assets
      config.assets.enabled = true
      config.serve_static_assets = true

      # allow cross origin policy
      config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins '*'
          resource '*', headers: :any, methods: [:get, :post, :options]
        end
      end
      config.action_dispatch.default_headers['P3P'] = 'CP="Not used"'
      config.action_dispatch.default_headers.delete('X-Frame-Options')

      #define ENV
      config.before_configuration do
        env_file = File.join(Rails.root, 'config', "\#{ENV['RAILS_ENV']}_env.yml")
        YAML.load(File.open(env_file)).each do |key, value|
          ENV[key.to_s] = value
        end if File.exists?(env_file)
      end


      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration can go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded after loading
      # the framework and any gems in your application.

      # Don't generate system test files.
      config.generators.system_tests = nil
      config.api_version = '2019-04'

    end
  end

RUBY
text = File.read('config/application.rb')
new_contents = text.gsub("\#", "#")
File.open('config/application.rb', "w") {|file| file.puts new_contents }


  # Product Create Job
  ########################################
  file 'app/jobs/products_create_job.rb', <<-RUBY
  class ProductsCreateJob < ApplicationJob
    queue_as :default

    def perform(*params)
      p "____________CreateJob___________________"
     # Do something later
    end
  end
RUBY

  ### Shopify APP
  file 'app/javascript/packs/application.js', <<-JS
import "bootstrap";
JS

  run 'rm app/javascript/packs/hello_react.jsx'
  file 'app/javascript/packs/hello_react.jsx', <<-JS
  import React from 'react'
  import ReactDOM from 'react-dom'
  import Main from '../components/main'
  import '@shopify/polaris/styles.css';
  import {AppProvider, Page, Card, Button} from '@shopify/polaris';

  document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
      <AppProvider>
        <Page title="Example app">
          <Main />
          <Card sectioned>
            <Button onClick={() => alert('Button clicked!')}>Example button</Button>
          </Card>
        </Page>
      </AppProvider>,
      document.getElementById('app'),
    )
  })

JS


  file 'app/javascript/components/main.jsx', <<-JS
    import React, { Component } from 'react';
  import ResourcesList from './resources_list'


  class Main extends Component {
    constructor(props) {
      super(props)
      this.state = {
        products: []
      };
    }

    componentDidMount() {
      this.fetchProducts({page_id: 1})
      // this.fetchSchedules()
    }

    handlePageChange = (params) => {
      this.fetchProducts(params)
    }

    fetchProducts = (params) => {
      fetch(`/api/v1/products?page=${params["page_id"]}&title=${params["searchValue"]}`, {
        method: 'GET',
        // body: JSON.stringify({active_page: this.state.activePage}), // or 'PUT',
        headers:{
          'Content-Type': 'application/json'
        }
      }).then(res => res.json())
      .then( (response) =>  {
        console.log(response.products),
        this.setState({ products: response.products }) })
      .catch(error => console.error('Error:', error));
    }


    render() {
      return (
        <div>
          <ResourcesList
            products={this.state.products}
            products_count={this.state.products_count}
            handlePageChange={this.handlePageChange}
            fetchProducts={this.fetchProducts}
          />
            <br/>
          <h3>Mes listes</h3>
            <br/>
        </div>

      );
    }
  }

  export default Main;

JS

  file 'app/javascript/components/resources_list.jsx', <<-JS
  import React, { Component } from 'react';
import {Avatar, Card, List, ResourceList, FilterType, Select, TextField, TextStyle, Pagination } from '@shopify/polaris';


class ResourcesList extends Component {
  state = {
    searchValue: '',
    appliedFilters: [
      // {
      //   key: 'accountStatusFilter',
      //   value: 'Account enabled',
      // },
    ],
    page_id: 1,
    isFirstPage: true,
    isLastPage: false,
  };

  handleSearchChange = (searchValue) => {
    this.setState({searchValue: searchValue});
    this.props.fetchProducts({page_id: 1, searchValue: searchValue })

  };

  handleFiltersChange = (appliedFilters) => {
    this.setState({appliedFilters});
  };

  // PAGINATION
  nextPage = () => {
    console.log('Next');
    this.setState({page_id: this.state.page_id += 1})
    this.setState({isFirstPage: false})
    this.props.handlePageChange({page_id: this.state.page_id })
  };

  prevPage = () => {
    console.log('Previous');
    this.setState({page_id: this.state.page_id -= 1});
    (this.state.page_id == 1) ? this.setState({isFirstPage: true}) : '';
    this.props.handlePageChange({page_id: this.state.page_id });
  };
  // PAGINATION


  renderItem = (item) => {
    const {id, url, title, image, published_at} = item;
    const img_src = image ? image.src : `https://via.placeholder.com/150/`
    const media = <img style={{maxHeight: "60px", width: "60px", objectFit: "contain"}} src={img_src} />;

    return (
      <ResourceList.Item id={id} url={url} media={media}>
          <TextStyle>{title}</TextStyle>
      </ResourceList.Item>
    );
  };

  render() {
    const resourceName = {
      singular: 'product',
      plural: 'products',
    };
    const {
      isFirstPage,
      isLastPage,
    } = this.state;

    const items = this.props.products;

    const filters = [
      {
        key: 'orderCountFilter',
        label: 'Number of orders',
        operatorText: 'is greater than',
        type: FilterType.TextField,
      },
      {
        key: 'accountStatusFilter',
        label: 'Account status',
        operatorText: 'is',
        type: FilterType.Select,
        options: ['Enabled', 'Invited', 'Not invited', 'Declined'],
      },
    ];

    const filterControl = (
      <ResourceList.FilterControl
        filters={filters}
        appliedFilters={this.state.appliedFilters}
        onFiltersChange={this.handleFiltersChange}
        searchValue={this.state.searchValue}
        onSearchChange={this.handleSearchChange}
        additionalAction={{
          content: 'Save',
          onAction: () => this.props.handlePageChange({ searchValue: this.state.searchValue })
        }}
      />

    );

    return (
      <Card>
        <ResourceList
          resourceName={resourceName}
          items={items}
          renderItem={this.renderItem}
          filterControl={filterControl}

        />
        <Pagination
          hasPrevious={!isFirstPage}
          hasNext={items.length == 10 }
          onPrevious={this.prevPage}
          onNext={this.nextPage}
        />
      </Card>
    );
  }
}

export default ResourcesList;



JS

run 'rm package.json'
file 'package.json', <<-JS
  {
    "name": "app5",
    "private": true,
    "dependencies": {
      "@babel/preset-react": "^7.0.0",
      "@rails/webpacker": "^4.0.7",
      "@shopify/polaris": "^3.20.0",
      "babel-plugin-transform-react-remove-prop-types": "^0.4.24",
      "bootstrap": "3",
      "jquery": "^3.4.1",
      "prop-types": "^15.7.2",
      "react": "^16.9.0",
      "react-dom": "^16.9.0"
    },
    "devDependencies": {
      "webpack-dev-server": "^3.7.2"
    }
  }

JS

run 'rm app/assets/stylesheets/application.scss'
file 'app/assets/stylesheets/application.scss', <<-TXT
  // Graphical variables
  @import "config/fonts";
  @import "config/colors";
  @import "config/bootstrap_variables";

  // External libraries
  // @import bootstrap/scss/bootstrap;
  @import "font-awesome-sprockets";
  @import "font-awesome";

  // Your RUBY partials
  @import "components/index";
  @import "pages/index";

TXT

run 'rm app/views/home/index.html.erb'
file 'app/views/home/index.html.erb', <<-HTML
<h2>Products</h2>

<%= javascript_pack_tag 'hello_react' %>

<div id="app"></div>

<ul>
  <% @products.each do |product| %>
    <li><%= link_to product.title, "https://\#{@shop_session.domain}/admin/products/\#{product.id}", target: "_top" %></li>
  <% end %>
</ul>

<hr>

<h2>Webhooks</h2>

<% if @webhooks.present? %>
  <ul>
    <% @webhooks.each do |webhook| %>
      <li><%= webhook.topic %> : <%= webhook.address %></li>
    <% end %>
  </ul>
<% else %>
  <p>This app has not created any webhooks for this Shop. Add webhooks to your ShopifyApp initializer if you need webhooks</p>
<% end %>

HTML



#RECURRING CHARGE
if RECURRING

# controller
file 'app/controllers/recurring_application_charges_controller.rb', <<-RUBY
  class RecurringApplicationChargesController < ApplicationController
    before_action :load_current_recurring_charge
    # before_action :create

    def show
      @recurring_application_charge
    end

    def create_free_plan
      unless ShopifyAPI::RecurringApplicationCharge.current
        @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new({
                name: "Free Plan",
                price: 0,
                return_url: callback_recurring_application_charge_url,
                test: true,
                trial_days: 0,
                capped_amount: 100,
                terms: "10 events"},)
        if @recurring_application_charge.save
          @tokens = @recurring_application_charge.confirmation_url
          redirect_to @recurring_application_charge.confirmation_url
        end
      else
        redirect_to_correct_path(@recurring_application_charge)
      end
      # @recurring_application_charge.try!(:cancel)
    end

    def create_silver_plan
      # unless ShopifyAPI::RecurringApplicationCharge.current
          @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new({
                  name: "19 Plan",
                  price: 19,
                  return_url: callback_recurring_application_charge_url,
                  test: true,
                  trial_days: 19,
                  # capped_amount: 4.99,
                  terms: "Great things"
                },)
          if @recurring_application_charge.save
            @tokens = @recurring_application_charge.confirmation_url
            redirect_to @recurring_application_charge.confirmation_url
          end

      # else
      #   redirect_to_correct_path(@recurring_application_charge)
      # end
    end

    def create_gold_plan
      unless ShopifyAPI::RecurringApplicationCharge.current
          @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new({
                  name: "Calendar Easy Gold Plan",
                  price: 11.99,
                  return_url: callback_recurring_application_charge_url,
                  trial_days: 15,
                  capped_amount: 100,
                  terms: "unlimited events, google cal sync"},)
          if @recurring_application_charge.save
            @tokens = @recurring_application_charge.confirmation_url
            redirect_to @recurring_application_charge.confirmation_url
          end

      else
        redirect_to_correct_path(@recurring_application_charge)
      end
    end

    def customize
      @recurring_application_charge.customize(params[:recurring_application_charge])
      fullpage_redirect_to @recurring_application_charge.update_capped_amount_url
    end

    def callback
      @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
      if @recurring_application_charge.status == 'accepted'
        @recurring_application_charge.activate
      end
      redirect_to_correct_path(@recurring_application_charge)
    end

    def destroy
      @recurring_application_charge.cancel

      flash[:success] = "Recurring application charge was cancelled successfully"

      redirect_to_correct_path(@recurring_application_charge)
    end

    private

    def load_current_recurring_charge
      @recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.current
    end

    def recurring_application_charge_params
      params.require(:recurring_application_charge).permit(
        :name,
        :price,
        :capped_amount,
        :terms,
        :trial_days
      )
    end

    def redirect_to_correct_path(recurring_application_charge)
      if recurring_application_charge.try(:capped_amount)
        redirect_to home_path
      else
        redirect_to home_path
      end
    end

  end



RUBY

  run 'rm app/controllers/home_controller.rb'
  file 'app/controllers/home_controller.rb', <<-RUBY
    # frozen_string_literal: true
    class HomeController < ShopifyApp::AuthenticatedController
      layout "application"
      before_action :set_plan
      before_action :protect_plan, except: :index

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

        if @plan
          redirect_to home_url
        end
      end

      private

      def set_plan
        @plan = ShopifyAPI::RecurringApplicationCharge.current
      end

      def protect_plan
        if !@plan
          redirect_to root_url
        end
      end
    end








RUBY

# show.html
file 'app/views/recurring_application_charges/show.html.erb', <<-HTML
  <script type="text/javascript">
    ShopifyApp.ready(function(){
      ShopifyApp.Bar.initialize({
        title: "Recurring Charge",
        icon: "<%#= asset_path('favicon.png') %>"
      });
    });
  </script>

  <% flash.each do |key, value| %>
    <div class="alert alert-<%= key %>"><%= value %></div>
  <% end %>

  <%# if @recurring_application_charge.present? && !@recurring_application_charge.try(:capped_amount) %>
    <div class="section">
      <div class= "col-md-3">
        <h4>
          Recurring Charge
        </h4>

        <p>
          Here you can see the terms of the recurring charge.
        </p>
      </div>

      <div class="col-md-9">
        <div class="panel panel-default">
          <div class="panel-body">
            <table class="table table-hover">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Price</th>
                  <th>Trial Days</th>
                  <th>Billing On</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>
                    <%= @recurring_application_charge.name %>
                  </td>
                  <td>
                    <%= @recurring_application_charge.price %>
                  </td>
                  <td>
                    <%= @recurring_application_charge.trial_days %>
                  </td>
                  <td>
                    <%= @recurring_application_charge.billing_on %>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <hr />

    <p>Si j'ai le free paln je peux upgrader to silver and gold + description</p>
    <p>Si j'ai le silver plan je peux upgrader to gold</p>
    <p>si j'ai le gold je peux desinstaller l'app</p>
    <div class="section">
      <div class= "col-md-3">
      </div>
      <div class="col-md-9">
        <p>
          <%= link_to 'Cancel charge', recurring_application_charge_path, method: :delete, class: "btn btn-danger" %>
        </p>
      </div>
    </div>

  <%# else %>

  <%# end %>


HTML

# home.html
file 'app/views/home/home.html.erb', <<-HTML
  <h2>Products</h2>

  <%= javascript_pack_tag 'hello_react' %>

  <div id="app"></div>

  <ul>
    <% @products.each do |product| %>
      <li><%= link_to product.title, "https://\#{@shop_session.domain}/admin/products/\#{product.id}", target: "_top" %></li>
    <% end %>
  </ul>

  <hr>

  <h2>Webhooks</h2>

  <% if @webhooks.present? %>
    <ul>
      <% @webhooks.each do |webhook| %>
        <li><%= webhook.topic %> : <%= webhook.address %></li>
      <% end %>
    </ul>
  <% else %>
    <p>This app has not created any webhooks for this Shop. Add webhooks to your ShopifyApp initializer if you need webhooks</p>
  <% end %>



HTML



# index.html
run 'rm app/views/home/index.html.erb'
file 'app/views/home/index.html.erb', <<-HTML
   <% content_for :javascript do %>
  <script type="text/javascript">
  ShopifyApp.ready(function() {
    ShopifyApp.Bar.initialize({ title: "Home" });
  });
  </script>
  <% end %>
  <div class="container">
    <div class="row">


      <div class="description">
        <h1>Name of the APP</h1>
        <br>
        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nulla itaque facilis quasi provident explicabo perferendis non repellendus blanditiis expedita cumque voluptatem maiores voluptas veritatis odio, sunt necessitatibus perspiciatis molestias totam.</p>
        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Minus cumque ab distinctio, veritatis fugit, impedit animi. Officia illo, quos excepturi, sunt, odit a amet ex perferendis harum dicta consequuntur nulla.</p>
        <p></p>
      </div>


      <% if !@plan.nil? %>
        <p>Your current plan is
          <%= @plan.name %>
        </p>
      <% end %>
      <br>
      </div>
      <hr><br>
      <!-- If you have already an event go see your Calendar page -->
      <div class="row plan_cards">

          <div class="col-md-4">
            <%= link_to create_free_plan_recurring_application_charge_path do %>
            <div style="--top-bar-background:#00848e; --top-bar-color:#f9fafb; --top-bar-background-lighter:#1d9ba4;">
              <div class="Polaris-Card">
                <div class="Polaris-Card__Header">
                  <h2 class="Polaris-Heading">LET'S TRY - FREEMIUM</h2>
                  <h5>Have some stuff for free</h5>
                </div>
                <div class="Polaris-Card__Section">
                  <ul style="text-align: left">
                    <li>2 Things</li>
                    <li>3 other things</li>
                    <li>great support</li>
                  </ul>
                </div>
              </div>
            </div>
            <% end %>
          </div>
          <div class="col-md-4">
            <%= link_to create_silver_plan_recurring_application_charge_path do %>
            <div style="--top-bar-background:#00848e; --top-bar-color:#f9fafb; --top-bar-background-lighter:#1d9ba4;">
              <div class="Polaris-Card">
                <div class="Polaris-Card__Header">
                  <h2 class="Polaris-Heading">LET'S TRY - Silver</h2>
                  <h5>7 days trial, Stop when you want</h5>
                </div>
                <div class="Polaris-Card__Section">
                  <ul style="text-align: left">
                    <li>10 Things</li>
                    <li>unlimited other things</li>
                    <li>great support</li>
                  </ul>
                </div>
              </div>
            </div>
            <% end %>
          </div>
          <div class="col-md-4">
            <%= link_to create_gold_plan_recurring_application_charge_path do %>
            <div style="--top-bar-background:#00848e; --top-bar-color:#f9fafb; --top-bar-background-lighter:#1d9ba4;">
              <div class="Polaris-Card">
                <div class="Polaris-Card__Header">
                  <h2 class="Polaris-Heading">LET'S TRY - GOLD</h2>
                  <h5>7 days trial, Stop when you want</h5>
                </div>
                <div class="Polaris-Card__Section">
                  <ul style="text-align: left">
                    <li>unlimited things</li>
                    <li>unlimited other things</li>
                    <li>great support</li>
                  </ul>
                </div>
              </div>
            </div>
            <% end %>
          </div>

      </div>

  </div>






HTML

run 'rm app/helpers/application_helper.rb'
file 'app/helpers/application_helper.rb', <<-RUBY
  module ApplicationHelper
    def show_balance_warning?(charge)
      (charge.balance_used.to_f / charge.capped_amount.to_f) > 0.6
    end

    def balance_used_percentage(charge)
      (charge.balance_used.to_f / charge.capped_amount.to_f) * 100
    end
  end

RUBY










end
#RECURRING CHARGE



  inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
<<-JS
const webpack = require('webpack')

// Preventing Babel from transpiling NodeModules packages
environment.loaders.delete('nodeModules');

// Bootstrap 4 has a dependency over jQuery & Popper.js:
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default']
  })
)

JS
  end

  # Dotenv
  ########################################
  run 'touch .env'

  # Rubocop
  ########################################
  run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'


run 'rails yarn install'

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with minimal template from https://github.com/lewagon/rails-templates'"
end
