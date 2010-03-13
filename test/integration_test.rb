require 'test/test_helper'

class IntegrationController < ActionController::Base

  def baz
    render :text => <<-HTML
      <html>
        <head>
          <script>
            function perform_xhr(method, url) {
              var xhr = new XMLHttpRequest()
              xhr.open(method, url, false) //false == synchronous
              xhr.onreadystatechange = function() {
                if (this.readyState != 4) { return }
                document.getElementById("xhr_result").innerHTML = this.responseText
              }
              xhr.send(null) // POST request sends data here
            }
          </script>
        </head>
        <body>
          <div id="xhr_result">orig</div>
        </body>
      </html>
    HTML
  end

  def baz_xhr
    render :text => "xhr response"
  end
end

class IntegrationControllerTest < ActionController::IntegrationTest

  # TODO test xhr POST
  # TODO test xhr uris with initial "/"
  # TODO test xhr is mocked early, e.g. requests triggered on page load

  test "api" do
    assert_respond_to self, :execute_javascript
    assert_respond_to self, :js
  end

  ## xhr

  test "xhr calls controller" do
    get "baz"

    assert_equal "orig", js(<<-JS)
      document.getElementById("xhr_result").innerHTML
    JS
    assert_equal "xhr response", js(<<-JS)
      perform_xhr("GET", "baz_xhr")
      document.getElementById("xhr_result").innerHTML
    JS
  end

  test "xhr identifes properly" do
    get "baz"
    assert_nil request.headers['X-Requested-With']

    js(<<-JS)
      perform_xhr("GET", "baz_xhr")
    JS
    assert_equal "XMLHttpRequest", request.headers['X-Requested-With']
  end
end

