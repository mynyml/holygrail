require 'test/test_helper'

class Rails
  def self.root
    Pathname(__FILE__).dirname.parent.expand_path
  end
end

ActionController::Routing::Routes.draw do |map|
  map.connect '/foo',     :controller => 'holy_grails', :action => 'foo'
  map.connect '/bar',     :controller => 'holy_grails', :action => 'bar'
  map.connect '/baz',     :controller => 'holy_grails', :action => 'baz'
  map.connect '/baz_xhr', :controller => 'holy_grails', :action => 'baz_xhr'
end

ActionController::Base.session = {
  :key    => "_myapp_session",
  :secret => "some secret phrase" * 5
}

class HolyGrailsController < ActionController::Base

  def foo
    render :text => <<-HTML
      <html>
        <head>
          <title>Foo</title>
        </head>
        <body>
          <div></div>
          <div></div>
        </body>
      </html>
    HTML
  end

  def bar
    render :text => <<-HTML
      <html>
        <head>
          <script src="/javascripts/application.js"></script>
          <script src='javascripts/foo.js'></script>
        </head>
        <body>
          <a href="/javascripts/application.js">local uri</a>
        </body>
      </html>
    HTML
  end

  def baz
    render :text => <<-HTML
      <html>
        <head>
          <script>
            function call_ajax() {
              var xhr = new XMLHttpRequest()
              xhr.open("GET", "/baz_xhr", false) //false == synchronous
              xhr.onreadystatechange = function() {
                alert("onreadystatechange: " + this.readyState)
                if (this.readyState != 4) { return }
                alert("before getElementBYId")
                alert(document.getElementById)
                document.getElementById("xhr_result").innerHTML = this.responseText
                alert(this.responseText)
              }
              xhr.send(null) // POST request sends data here
            }
            alert(window.location)
          </script>
        </head>
        <body>
          <div id="xhr_result">wrong</div>
        </body>
      </html>
    HTML
  end

  def baz_xhr
    render :text => "works"
  end
end

class HolyGrailsIntegrationTest < ActionController::IntegrationTest

  test "xhr calls controller" do
    $xhr_block = lambda do |params|
      p params["method"]
      p params["url"]
      send params["method"].downcase, params["url"]
      $xhr_reply = @response.body.to_s
    end

    get "baz"
    js("")

    @__page.execute_js(<<-JS)
      old_open = XMLHttpRequest.prototype.open

      XMLHttpRequest.prototype.open = function(method, url, async, username, password) {
        Ruby.holygrail_xhr_data = {
          method:   method,
          url:      url,
          async:    async,
          username: username,
          password: password
        }
      }

      old_send = XMLHttpRequest.prototype.send

      XMLHttpRequest.prototype.send = function(data) {
        //for (key in this) { print(key + ": " + this[key]) }
        Ruby.execute_xhr()
        this.responseText = Ruby.xhr_reply()
        // Also do response code
        this.readyState = 4
        this.onreadystatechange()
      }
    JS

    js("call_ajax()")

    puts js("window.harmony_request")

    js(<<-JS)
      foo = document.getElementById("xhr_result")
    JS
    assert_equal "works", js("foo.innerHTML")
  end
end

class HolyGrailsControllerTest < ActionController::TestCase
  test "api" do
    assert_respond_to self, :execute_javascript
    assert_respond_to self, :js
  end

  test "parses simple js" do
    assert_equal 2, js('1+1')
  end

  test "every test is a different context" do
    js("foo = 'bar'")
    assert_equal 'bar', js('foo')
  end
  test "every test is a different context 2" do
    assert_raises(Johnson::Error) { js('foo') }
  end

  test "response context doesn't bleed into next response" do
    get :foo
    js("foo = 'bar'")
    assert_equal 'bar', js('foo')

    get :foo
    assert_raises(Johnson::Error) { js('foo') }
  end

  test "DOM" do
    get :foo
    assert_equal 'Foo', js("document.title")
    assert_equal  2,    js("document.getElementsByTagName('div').length")
  end

  test "resolves <script scr> URIs" do
    get :bar
    assert_equal 'grail', js("holy()") #src with double quotes + absolute path
    assert_equal 'foo',   js("foo()")  #src with single quotes + relative path

    # other paths should be left intact
    assert_equal '/javascripts/application.js',
      js("document.getElementsByTagName('a')[0].href")
  end
end

