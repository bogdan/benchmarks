require "diffbench"
require "ruby-prof"
$:.unshift "../railties/lib"
$:.unshift "../activesupport/lib"
require "active_support"
require 'rails'
require 'perftools'
          
GC.disable
class App < Rails::Application
  # Enable the asset pipeline
  config.assets.enabled = true
end


def draw_routes
  App.routes.draw do 
    resources :inboxes do
      resources :messages do
        resources :attachments
      end
    end

    namespace :admin do
      resources :users
    end

    scope "/returns/:return" do
      resources :objects
    end
    resources :returns

    scope "(/optional/:optional_id)" do
      resources :things
    end
    
    get "/other_optional/(:optional_id)" => "foo#foo", :as => :foo

    get 'books/*section/:title' => 'books#show', :as => :book
  end
end
draw_routes


def url_helpers_module
  routes = App.routes
  Module.new do
    extend ActiveSupport::Concern
    include ActionDispatch::Routing::UrlFor

    # Define url_for in the singleton level so one can do:
    # Rails.application.routes.url_helpers.url_for(args)
    @_routes = routes
    class << self
      delegate :url_for, :optimize_routes_generation?, :url_options, :to => '@_routes'
      def url_options
        {}
      end
    end

    # Make named_routes available in the module singleton
    # as well, so one can do:
    # Rails.application.routes.url_helpers.posts_path
    extend routes.named_routes.module

    # Any class that includes this module will get all
    # named routes...
    include routes.named_routes.module

    # plus a singleton class method called _routes ...
    included do
      singleton_class.send(:redefine_method, :_routes) { routes }
    end

    # And an instance method _routes. Note that
    # UrlFor (included in this module) add extra
    # conveniences for working with @_routes.
    define_method(:_routes) { @_routes || routes }
  end
end

url_helpers = url_helpers_module

PerfTools::CpuProfiler.start("/tmp/perf") do
  100000.times do
      url_helpers.inbox_path(1)
  end
end

#result = RubyProf.profile do
  #url_helpers.inbox_message_path(2, id: 1)
#end
#printer = RubyProf::CallTreePrinter.new(result)
#printer.print(STDOUT, {})

DiffBench.bm do
  report "draw routes" do
    10.times do
      draw_routes
    end
  end

  report "simple URL generation" do
    1000.times do
      url_helpers.inbox_path(1)
    end
  end

  report "URL generation with params as hash" do
    1000.times do
      url_helpers.inbox_message_path(inbox_id: 1, id: 2)
    end
  end
  report "URL generation with handle_positional_args" do
    1000.times do
      url_helpers.inbox_message_path(2, id: 1)
    end
  end
  report "URL generation with globbing" do
    1000.times do
      url_helpers.book_path(10, "hello")
    end
  end

  report "handle_positional_args" do
    1000.times do
      url_helpers.send(:handle_positional_args, [1,2], {key: true}, [:inbox_id, :id])
    end
  end
end


GC.enable
