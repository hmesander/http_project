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
    closed = false
    until closed
      @client = @tcp_server.accept
      request
      if @path[0..12] == '/word_search'
        word_search
      elsif @path == '/start_game'
        @client.puts begin_game
      elsif @path == '/'
        @client.puts output_diagnostic
      elsif @path == '/hello'
        @client.puts output_hello
        @hello_counter += 1
      elsif @path == '/datetime'
        @client.puts output_date
      elsif @path == '/shutdown'
        @client.puts output_shutdown
        closed = true
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
    "Verb: #{@verb}\nPath: #{@path}\nProtocol: #{@protocol}\nHost: #{@host}\nPort: #{@port}\nOrigin: #{@origin}\nAccept: #{@accept}"
  end

  def output_diagnostic
    output = "<pre>#{formatted_request}\n\n</pre>"
    @output_length = output.length
    @client.puts headers
    output
  end

  def output_hello
    output = "<pre>Hello, World! (#{@hello_counter})</pre>"
    @output_length = output.length
    @client.puts headers
    output
  end

  def output_date
    output = "<pre>#{Time.now.strftime('%l:%M%p')} on #{Date.today.strftime('%A, %B %e, %Y')}</pre>"
    @output_length = output.length
    @client.puts headers
    output
  end

  def output_shutdown
    shutdown = "Total Requests: #{@total_requests}"
    @output_length = shutdown.length
    @client.puts headers
    shutdown
  end

  def headers
    ['http/1.1 200 ok',
     "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
     'server: ruby',
     'content-type: text/html; charset=iso-8859-1',
     "content-length: #{@output_length}\r\n\r\n"].join("\r\n")
  end

  def word_search
    path_array = @path.split('?')
    parameter_array = path_array[1].split('=')
    @word = parameter_array[1]
    search_dictionary
  end

  def search_dictionary
    dictionary = File.readlines('/usr/share/dict/words')
    found = dictionary.any? do |line|
      line.include?(@word)
    end
    if found
      output = "#{@word.upcase} is a known word."
      @output_length = output.length
      @client.puts headers
      @client.puts output
    else
      output = "#{@word.upcase} is not a known word."
      @output_length = output.length
      @client.puts headers
      @client.puts output
    end
  end

  def begin_game
    'Good luck!'
  end

  def guessing_game
    answer = rand(0..100)
  end

end
