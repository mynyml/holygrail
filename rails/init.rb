require 'pathname'
require  Pathname(__FILE__).dirname.parent + 'lib/holygrail'

class ActionController::TestCase
  include ActionController::Assertions::HolyGrail
end
class ActionController::IntegrationTest
  include ActionController::Assertions::HolyGrail
end
