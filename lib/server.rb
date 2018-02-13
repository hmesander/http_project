require 'socket'
require 'pry'
require 'Date'
require 'time'

class Server
  def initialize
    @tcp_server     = TCPServer.new(9292)
    @hello_counter  = 0
    @total_requests = 0
    @verb           = nil
    @path           = nil
    @protocol       = nil
    @host           = nil
    @port           = nil
    @origin         = nil
    @accept         = nil
  end

  def process
    while true
      @client = @tcp_server.accept
      request
      @client.puts headers
      if @path[0..13] == '/word_search?' && @verb == 'GET'
        word_search
      elsif @path == '/'
        @client.puts output_diagnostic
      elsif @path == '/hello'
        @client.puts output_hello
      elsif @path == '/datetime'
        @client.puts output_date
      elsif @path == '/shutdown'
        @client.puts output_shutdown
      end
      @total_requests += 1
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

  def output_diagnostic
    "<pre>#{formatted_request}\n\n</pre>"
  end

  def output_hello
    "<pre>Hello, World! (#{@hello_counter}</pre>"
    @hello_counter += 1
  end

  def output_date
    "<pre>#{Time.now.strftime('%l:%M')} on #{Date.today.strftime('%A, %B %e, %Y')}</pre>"
  end

  def output_shutdown
    shutdown = "Total Requests: #{@total_requests}"
    @client.close
    shutdown
  end

  def headers
    ['http/1.1 200 ok',
     "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
     'server: ruby',
     'content-type: text/html; charset=iso-8859-1',
     "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

  def word_search
    path_array = @path.split('?')
    parameter_array = path_array[1].split('=')
    @word = parameter_array[1]
    search_dictionary
  end

  def search_dictionary
    found = File.read('./dictionary.txt').include?(@word)
    if found == true
      @client.puts "#{@word.upcase} is a known word."
    else
      @client.puts "#{@word.upcase} is not a known word."
    end
  end

end
