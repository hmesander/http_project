require 'faraday'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/server'
require './lib/client'

class ServerTest < Minitest::Test
  def test_that_server_exists
    skip
    server = Server.new

    assert_instance_of Server, server
  end

  def test_that_server_responds_on_9292_host
    skip
    response = Faraday.get 'http://localhost:9292'
    assert_equal "Hello, World! (0)\n\n</pre>", response.body

    response = Faraday.get 'http://localhost:9292'
    assert_equal "Hello, World! (1)\n\n</pre>", response.body

    response = Faraday.get 'http://localhost:9292'
    assert_equal "Hello, World! (2)\n\n</pre>", response.body
  end

  def test_that_server_can_respond_with_request_details
    skip
    formatted_request = "Verb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: localhost\n
                         Port: 9292\nOrigin: 0501bb48-d1e5-2538-765f-5fd213c384af\n
                         Accept: */*"
    expected = "<pre>Hello, World! (0)\n\n#{formatted_request}\n\n</pre>"
    response = Faraday.get 'http://localhost:9292'

    assert_equal expected, response.body
  end

  def test_that_server_can_respond_to_given_path
    response = Faraday.get 'http://localhost:9292'
    formatted_request = 'Verb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: localhost\n
                         Port: 9292\nOrigin: 0501bb48-d1e5-2538-765f-5fd213c384af\n
                         Accept: */*'
    assert_equal formatted_request, response.body
  end
end
