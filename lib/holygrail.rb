require 'harmony'

module HolyGrail

  # This module allows routing ajax requests to rails controllers
  #
  # @private
  module XhrProxy
    extend self

    # Test object context (i.e. within test methods)
    attr_accessor :context

    # Surrogate ajax request
    def request(info, data="")
      context.instance_eval do
        xhr(info["method"].downcase, info["url"], data)
        @response.body.to_s
      end
    end
  end

  module Extensions

    # JS script to reroute ajax requests through XhrProxy
    #
    # @private
    XHR_MOCK_SCRIPT = <<-JS
    <script>
      XMLHttpRequest.prototype.open = function(method, url, async, username, password) {
        this.info = { method: method, url: url }
      }
      XMLHttpRequest.prototype.send = function(data) {
        this.responseText = Ruby.HolyGrail.XhrProxy.request(this.info, data)
        this.readyState = 4
        this.onreadystatechange()
      }
    </script>
    JS

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
      XhrProxy.context = self
      @__page ||= Harmony::Page.new(XHR_MOCK_SCRIPT + referrer_mock_script + rewrite_script_paths(@response.body.to_s))
      Harmony::Page::Window::BASE_RUNTIME.wait
      @__page.execute_js(code)
    end
    alias :execute_javascript :js

    private

    # Mock javascript to set document.referrer
    #
    # Sets the referrer using the value from @request.env['HTTP_REFERER'].
    # If there is no HTTP_REFERER request header, no script is returned.
    #
    # @return [String]
    #   HTML script element
    #
    def referrer_mock_script
      return '' if @request.env['HTTP_REFERER'].nil?

      <<-JS
      <script>
        document._referrer = #{@request.env['HTTP_REFERER'].to_json};
      </script>
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
