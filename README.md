HolyGrail
=========

Summary
-------

The Holy Grail of testing for front-end development; execute browser-less,
console-based, javascript + DOM code right from within your Rails test suite.

HolyGrail is a [Harmony][20] plugin for Ruby on Rails.

Examples
--------

Use the `js` method in your functional tests to execute javascript within the
context of a view (the last response body). `js` returns the value of the last
javascript statement, cast to an equivalent ruby object.

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

Install
-------

Install the gem

    # There's a gem dependency bug in rubygems currently, so we'll have to
    # install some dependencies manually. This will be fixed soon.
    gem install stackdeck
    gem install johnson -v "2.0.0.pre3" #exact version matters

    gem install holygrail

and add it to your environment

    config.gem "holygrail"

Acknowledgement
---------------

HolyGrail is based on [Harmony][20], which in turn is a thin DSL wrapper around
three **amazing** libs, [Johnson][1], [env.js][30] and [Envjs][2] . The authors
of those libs have been doing a huge amount of great work for quite a while, so
please go recommend them on WorkingWithRails right now and/or follow them on
github:

  [jbarnette][3], [tenderlove][4], [smparkes][5], [wycats][6], [matthewd][7], [thatcher][8], [jeresig][9]

Special thanks go to [smparkes][10] for his patient help, and for providing the
last puzzle pieces that made [everything][12] [work][11] [together][13].

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
[11]: http://github.com/smparkes/env-js/commit/49abe259813a505b0761e6d31dde671344b5bc87#L0R279
[12]: http://groups.google.com/group/envjs/msg/4ac719f7db7912f5
[13]: http://gemcutter.org/gems/envjs
[20]: http://github.com/mynyml/harmony
[30]: http://github.com/thatcher/env-js
