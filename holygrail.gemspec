Gem::Specification.new do |s|
  s.name                = "holygrail"
  s.version             = "0.6.2.reevoo"
  s.summary             = "Harmony plugin for Ruby on Rails tests"
  s.description         = "The Holy Grail of testing for front-end development; execute browser-less, console-based, javascript + DOM code right from within your Rails test suite."
  s.author              = "mynyml"
  s.email               = "mynyml@gmail.com"
  s.homepage            = "http://github.com/mynyml/holygrail"
  s.rubyforge_project   = "holygrail"
  s.require_path        = "lib"
  s.files               =  File.read("Manifest").strip.split("\n")

  s.add_dependency 'harmony'
  s.add_development_dependency 'action_controller'
end
