require 'pathname'
require  Pathname(__FILE__).dirname.parent + 'lib/holygrail'

class ActionController::TestCase
  include HolyGrail::Assertions
end
class ActionController::IntegrationTest
  include HolyGrail::Assertions
end
