require 'faraday'
require 'minitest/autorun'
require 'minitest/pride'

class ServerTest < Minitest::Test
  def test_that_server_responds_on_9292_host
    response = Faraday.get 'http://localhost:9292'
    assert_equal 'Hello, World! (0)', response.body

    response = Faraday.get 'http://localhost:9292'
    assert_equal 'Hello, World! (1)', response.body
  end
end
