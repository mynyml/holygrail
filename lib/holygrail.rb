require 'harmony'

module ActionController
  module Assertions
    module HolyGrail
      def execute_javascript(code)
        @__page ||= Harmony::Page.new(@response.body)
        @__page.execute_js(code)
      end
      alias :js :execute_javascript
    end
  end
end
