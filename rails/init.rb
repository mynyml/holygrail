require 'pathname'
require  Pathname(__FILE__).dirname.parent + 'lib/holygrail'

class ActionController::TestCase
  include HolyGrail::Extensions
end
class ActionController::IntegrationTest
  include HolyGrail::Extensions
end
