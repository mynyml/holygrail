HolyGrail
=========

Summary
-------

The Holy Grail of testing for front-end development; execute browser-less,
console-based, javascript + DOM code right from within your Rails test suite.

HolyGrail is a [Harmony][11] plugin for Ruby on Rails.

Install
-------
Install the gem

    gem install holygrail

and add it to your environment

    config.gem "holygrail"

Examples
--------

Use the `js` method in your functional tests to execute javascript within the context of a view

    class PeopleControllerTest < ActionController::TestCase

      test "executes simple js" do
        assert_equal 2, js('1+1')
      end

      test "accesses the DOM" do
        get :foo
        assert_equal 'Foo', js("document.title")
        assert_equal  2,    js("document.getElementsByTagName('div').length")
      end
    end

Acknowledgement
---------------

HolyGrail is based on [Harmony][11], which in turn is a very thin DSL wrapper
around two **amazing** libs, [Johnson][1] and [Envjs][2]. The
authors/contributors of those libs have been doing a huge amount of great work
for quite a while, so please go recommend them on WorkingWithRails right now
and/or follow them on github:

  [jbarnette][3], [tenderlove][4], [smparkes][5], [wycats][6], [matthewd][7], [thatcher][8], [jeresig][9]

Special thanks go to [smparkes][10] for his patient help, and for providing the
last bit of glue that made everything work together.

TODO
----
* Support integration tests
* Support Rails3

Links
-----
* code: <http://github.com/mynyml/holygrail>
* docs: <http://yardoc.org/docs/mynyml-holygrail>
* wiki: <http://wiki.github.com/mynyml/holygrail>
* bugs: <http://github.com/mynyml/holygrail/issues>



[1]:  http://github.com/jbarnette/johnson/
[2]:  http://env-js.appspot.com/
[3]:  http://www.workingwithrails.com/person/10668-john-barnette
[4]:  http://github.com/tenderlove/
[5]:  http://www.workingwithrails.com/person/11739-steven-parkes
[6]:  http://www.workingwithrails.com/person/1805-yehuda-katz
[7]:  http://www.workingwithrails.com/person/6221-matthew-draper
[8]:  http://github.com/thatcher/
[9]:  http://ejohn.org/
[10]: http://github.com/smparkes/
[11]: http://github.com/mynyml/harmony
