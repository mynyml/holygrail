require 'harmony'

module HolyGrail
  class XhrProxy
    class << self
      attr_accessor :context

      def request(info, data="")
        context.instance_eval do
          send(info["method"].downcase, info["url"])
          @response.body.to_s
        end
      end
    end
  end
end

module ActionController
  module Assertions
    module HolyGrail

      # Clear harmony page on every request.
      # Prevents changes to context from bleeding into the next one.
      #
      # @example
      #
      #     get :index
      #     js("foo = 'bar'")
      #     js('foo') #=> "bar"
      #
      #     get :index
      #     js('foo') #=> "Error: foo is not defined"
      #
      # @private
      def process(*args) #:nodoc:
        ::HolyGrail::XhrProxy.context = self
        @__page = nil
        super
      end

      # Execute javascript within the context of a view.
      #
      # @example
      #
      #     class PeopleControllerTest < ActionController::TestCase
      #       get :index
      #       assert_equal 'People: index', js('document.title')
      #     end
      #
      # @param [String]
      #   code javascript code to evaluate
      #
      # @return [Object]
      #   value of last javascript statement, cast to an equivalent ruby object
      #
      # @raise [Johnson::Error]
      #   javascript code exception
      #
      def js(code)
        @__page ||=
          begin
            page = Harmony::Page.new(rewrite_script_paths(@response.body.to_s))
            page.execute_js(mock_xhr)
            page
          end
        @__page.execute_js(code)
      end
      alias :execute_javascript :js

      private

      def mock_xhr
        <<-JS
        XMLHttpRequest.prototype.open = function(method, url, async, username, password) {
          this.info = { method: method, url: url }
        }
        XMLHttpRequest.prototype.send = function(data) {
          this.responseText = Ruby.HolyGrail.XhrProxy.request(this.info, data)
          this.readyState = 4
          this.onreadystatechange()
        }
        JS
      end

      # Rewrite relative src paths in <script> tags
      #
      # <script src> tags point to js files relative to public/ directory.
      # Harmony needs paths to the local files instead so that it can load
      # them.
      #
      # @param [String] body
      #   document for which to rewrite script paths
      #
      # @return [String]
      #   updated body
      #
      def rewrite_script_paths(body)
        body.gsub(%r%src=("|')/?javascripts/(.*)("|')%) { %|src=#{$1}%s#{$1}"| % Rails.root.join("public/javascripts/#{$2}") }
      end
    end
  end
end
