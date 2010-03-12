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

class HolyGrailsIntegrationTest < ActionController::IntegrationTest

  # TODO test post xhr

  test "api" do
    assert_respond_to self, :execute_javascript
    assert_respond_to self, :js
  end

  test "xhr calls controller" do
    HolyGrail::XhrProxy.context = self

    get "baz"

    assert_equal "orig", js(<<-JS)
      document.getElementById("xhr_result").innerHTML
    JS
    assert_equal "xhr response", js(<<-JS)
      perform_xhr("GET", "/baz_xhr")
      document.getElementById("xhr_result").innerHTML
    JS
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

