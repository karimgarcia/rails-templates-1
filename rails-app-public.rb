run 'pgrep spring | xargs kill -9'


p "enter my APIKEY: "
p "(if you don't, create a new app in your partner shoify account)"

API_KEY = STDIN.gets.downcase.chomp

p "enter my SECRETKEY: "
SECRET_KEY = STDIN.gets.downcase.chomp

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

#{"gem 'bootsnap', require: false" if Rails.version >= "5.2"}
# gem 'devise'
gem 'jbuilder', '~> 2.0'
gem 'pg', '~> 0.21'
gem 'puma'
gem 'rails', '#{Rails.version}'
gem 'redis'

gem 'autoprefixer-rails'
gem 'bootstrap', '~> 4.3.1'
gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-sass', '~> 5.0.9'
gem 'sass-rails'
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

run 'curl -L https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb'
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
  APP_NAME: 'Shopify APP'
  SHOPIFY_CLIENT_API_KEY: #{API_KEY}
  SHOPIFY_CLIENT_API_SECRET: #{SECRET_KEY}

RUBY


  # Devise install + user
  ########################################
  # generate('devise:install')
  # generate('devise', 'User')

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ShopifyApp::AuthenticatedController
  protect_from_forgery with: :exception
  # before_action :authenticate_user!
end
RUBY


  # migrate + devise views
  ########################################
  # rails_command 'db:migrate'
  # generate('devise:views')

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
  run 'yarn add jquery bootstrap@3'
  run 'yarn add @shopify/polaris'
  ### Shopify APP



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

# run 'rm .env'
# file '.env', <<-RUBY
#   SHOPIFY_CLIENT_API_KEY=API_KEY
#   SHOPIFY_CLIENT_API_SECRET=SECRET_KEY
# RUBY

  # Shop model
  ########################################
  run 'rm app/models/shop.rb'
  file 'app/models/shop.rb', <<-RUBY
  class Shop < ActiveRecord::Base
    include ShopifyApp::SessionStorage

    def connect_to_store
      session = ShopifyAPI::Session.new(self.shopify_domain, self.shopify_token)
      session.valid?
      ShopifyAPI::Base.activate_session(session)
    end

    def api_version
      ShopifyApp.configuration.api_version
    end
  end

RUBY
  # Application Job
  ########################################
  run 'rm app/controllers/home_controller.rb'
  file 'app/controllers/home_controller.rb', <<-RUBY
  # frozen_string_literal: true
  class HomeController < ShopifyApp::AuthenticatedController
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
      this.fetchProducts(1)
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
      {
        key: 'accountStatusFilter',
        value: 'Account enabled',
      },
    ],
    page_id: 1,
    isFirstPage: true,
    isLastPage: false,
  };

  handleSearchChange = (searchValue) => {
    this.setState({searchValue});
    console.log(this.state.searchValue);
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

run 'rm config/application.rb'
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


  inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
<<-JS
// Bootstrap 3 has a dependency over jQuery:
const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery'
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

  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with devise template from https://github.com/sativva/rails-templates'"
end

     # Consult this page for more scope options:
