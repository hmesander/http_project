require 'socket'

class Server
  attr_reader :client
  def initialize(port = 9292)
    @port = port
    @tcp_server = TCPServer.new(port)
    @client = tcp_server.accept
    @counter = 0
  end

  def headers
    ['http/1.1 200 ok',
     "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
     'server: ruby',
     'content-type: text/html; charset=iso-8859-1',
     "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

  def respond
    output = "Hello, World! (#{counter})"
    client.puts headers
    client.puts output
    @counter += 1
  end
end
