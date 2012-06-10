require 'test/test_helper'

class FunctionalsController < ActionController::Base

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
end

class FunctionalsControllerTest < ActionController::TestCase

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

  test "sets the document referrer correctly" do
    @request.env['HTTP_REFERER'] = 'http://example.com/page.html'
    get :foo

    assert_equal 'http://example.com/page.html', js("document.referrer")
  end

  test "not set the document referrer if there is no HTTP_REFERER header" do
    get :foo
    assert_not_nil js('document.referrer')
  end

  test "exposes URL anchors" do
    get :foo, :anchor => 'foo_123'
    assert_equal '#foo_123', js('window.location.hash')
  end
end

