require 'harmony'

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
      #
      def process(*args) #:nodoc:
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
      # @param [String] code javascript code to evaluate
      # @raise [Johnson::Error] javascript code exception
      # @return [Object] return value of last javascript statement, cast to an
      #   equivalent ruby object
      #
      def execute_javascript(code)
        @__page ||= Harmony::Page.new(@response.body.to_s)
        @__page.execute_js(code)
      end
      alias :js :execute_javascript
    end
  end
end
