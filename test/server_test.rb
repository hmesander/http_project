require 'faraday'
require 'minitest/autorun'
require 'minitest/pride'

class ServerTest < Minitest::Test
  def test_that_server_responds_on_9292_host
    expected = '<html><head></head><body><pre>Hello, World!</pre></body></html>'
    response = Faraday.get 'http://localhost:9292'

    assert_equal expected, response.body
  end
end
