require 'socket'
require 'pry'

class Server
  def initialize
    @tcp_server    = TCPServer.new(9292)
    @hello_counter = 0
    @verb          = nil
    @path          = nil
    @protocol      = nil
    @host          = nil
    @port          = nil
    @origin        = nil
    @accept        = nil
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
    parse
  end

  def parse
    split_request = @request_lines.map do |string|
      string.split(' ')
    end
    @verb = split_request[0][0]
    @path = split_request[0][1]
    @protocol = split_request[0][2]
    @host = split_request[1][1].chop.chop.chop.chop.chop
    @port = split_request[1][1][-4..-1]
    @origin = split_request[5][1]
    @accept = split_request[6][1]
  end

  def formatted_request
    "Verb: #{@verb}\n
     Path: #{@path}\n
     Protocol: #{@protocol}\n
     Host: #{@host}\n
     Port: #{@port}\n
     Origin: #{@origin}\n
     Accept: #{@accept}"
  end

  def output
    output = "<pre>Hello, World! (#{@hello_counter})\n\n#{formatted_request}\n\n</pre>"
    headers = ['http/1.1 200 ok',
               "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
               'server: ruby',
               'content-type: text/html; charset=iso-8859-1',
               "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @client.puts headers
    @client.puts output
  end
end
