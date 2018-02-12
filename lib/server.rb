require 'socket'
require 'pry'

class Server
  def initialize(port = 9292)
    @port          = port
    @tcp_server    = TCPServer.new(port)
    @hello_counter = 0
  end

  def process
    while true
      @client = @tcp_server.accept
      request
      output
      @hello_counter += 1
    end
  end

  def request
    @request_lines = []
    while line = @client.gets and !line.chomp.empty?
      @request_lines << line.chomp
    end
  end

  def output
    formatted_request = "Verb: #{@request_lines[0][0..2]}\nPath: #{@request_lines[0][4]}\nProtocol: #{@request_lines[0][-8..-1]}\nHost: #{@request_lines[1][-14..-6]}\nPort: #{@request_lines[1][-4..-1]}\nOrigin: 127.0.0.1\n#{@request_lines[6]}"
    output = "<pre>Hello, World! (#{@hello_counter})\n\n" + formatted_request + '</pre>'
    headers = ['http/1.1 200 ok',
               "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
               'server: ruby',
               'content-type: text/html; charset=iso-8859-1',
               "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @client.puts headers + output
  end
end
