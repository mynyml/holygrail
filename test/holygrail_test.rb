require 'test/test_helper'

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'holy_grails', :action => 'foo'
end

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
    js("function foo() { return 'bar' }")
    assert_equal 'bar', js('foo()')
  end
  test "every test is a different context 2" do
    assert_raises(Johnson::Error) { js('foo()') }
  end

  test "DOM" do
    get :foo
    assert_equal 'Foo', js("document.title")
    assert_equal  2,    js("document.getElementsByTagName('div').length")
  end
end

