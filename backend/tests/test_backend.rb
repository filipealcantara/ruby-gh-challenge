ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'

# Local imports
require_relative '../backend'
require_relative '../gh_vars_module'

class BackendTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_returns_400_when_missing_params
    get '/', params={}
    assert_equal 400, last_response.status    
  end

  def test_it_returns_400_when_invalid_params
    get '/', params={:type => "a"}
    assert_equal 400, last_response.status    
  end
end