require 'simplecov'
SimpleCov.start
require 'faraday'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/server'

class ServerTest < Minitest::Test
  def test_that_server_can_respond_with_request_details
    expected = "<pre>Verb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: localhost\nPort: 9292\nOrigin: \nAccept: */*</pre>"
    response = Faraday.get 'http://localhost:9292/'

    assert_equal expected, response.body
  end

  def test_that_server_responds_with_hello_world
    response = Faraday.get 'http://localhost:9292/hello'
    assert_equal '<pre>Hello, World! (0)</pre>', response.body

    response = Faraday.get 'http://localhost:9292/hello'
    assert_equal '<pre>Hello, World! (1)</pre>', response.body

    response = Faraday.get 'http://localhost:9292/hello'
    assert_equal '<pre>Hello, World! (2)</pre>', response.body
  end

  def test_that_server_can_respond_with_date_time
    date = Date.today.strftime('%A, %B %e, %Y')
    time = Time.now.strftime('%l:%M%p')

    expected = "<pre>#{time} on #{date}</pre>"
    response = Faraday.get 'http://localhost:9292/datetime'

    assert_equal expected, response.body
  end

  def test_that_server_can_respond_with_
    skip
    post = Faraday.post 'http://localhost:9292/game'

    assert_equal 45, post
  end
end
