require 'faraday'
require 'minitest/autorun'
require 'minitest/pride'

class ServerTest < Minitest::Test
  def 
  def test_that_server_responds_on_9292_host
    skip
    response = Faraday.get 'http://localhost:9292'
    assert_equal 'Hello, World! (0)', response.body

    response = Faraday.get 'http://localhost:9292'
    assert_equal 'Hello, World! (1)', response.body

    response = Faraday.get 'http://localhost:9292'
    assert_equal 'Hello, World! (2)', response.body
  end

  def test_that_server_can_respond_with_request_details
    expected = "<pre>Hello, World! (0)\n\nVerb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: localhost\nPort: 9292\nOrigin: 127.0.0.1\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8</pre>"
    response = Faraday.get 'http://localhost:9292'

    assert_equal expected, response.body
  end
end
