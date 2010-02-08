require 'harmony'

module ActionController
  module Assertions
    module HolyGrail

      # Clear harmony page on every request.
      # Prevents changes to context from bleeding into the next one.
      #
      #     get :index
      #     js("foo = 'bar'")
      #     js('foo') #=> "bar"
      #
      #     get :index
      #     js('foo') #=> "Error: foo is not defined"
      #
      def process(*args) #:nodoc:
        @__page = nil
        super
      end

      def execute_javascript(code)
        @__page ||= Harmony::Page.new(@response.body)
        @__page.execute_js(code)
      end
      alias :js :execute_javascript
    end
  end
end
