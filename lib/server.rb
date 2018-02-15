require 'socket'
require 'Date'
require 'time'
require './lib/game'

class Server
  include Game
  def initialize
    @tcp_server     = TCPServer.new(9292)
    @hello_counter  = 0
    @total_requests = 0
    @closed         = false
    @guesses        = []
  end

  def initial_request_handler
    until @closed
      @client = @tcp_server.accept
      request_line_reader
      if @verb == 'GET'
        get_request_handler
      elsif @verb == 'POST'
        post_request_handler
      end
      @total_requests += 1
    end
  end

  def get_request_handler
    if @path == '/'
      output_diagnostic
    elsif @path == '/hello'
      output_hello
      @hello_counter += 1
    elsif @path == '/datetime'
      output_date
    elsif @path == '/shutdown'
      output_shutdown
    elsif @path[0..12] == '/word_search?'
      word_search
    elsif @path == '/game'
      game_stats
    end
  end

  def post_request_handler
    if @path == '/start_game'
      begin_game
    elsif @path == '/game'
      parse_post_body
    end
  end

  def request_line_reader
    request_lines = []
    while line = @client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end
    parse_headers(request_lines)
    parse_post_body(request_lines) if @verb == 'POST'
  end

  def parse_headers(request_lines)
    split_request = request_lines.map do |string|
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

  def parse_post_body(request_lines)
    request_lines.shift
    split_request = request_lines.map do |string|
      string.split(': ')
    end
    hash_request = split_request.to_h
    @content_length = hash_request['Content-Length'].to_i
    store_guess
  end

  def formatted_request
    "Verb: #{@verb}\nPath: #{@path}\nProtocol: #{@protocol}\nHost: #{@host}\nPort: #{@port}\nOrigin: #{@origin}\nAccept: #{@accept}"
  end

  def output_diagnostic
    output = "<pre>#{formatted_request}\n\n</pre>"
    @output_length = output.length
    @client.puts headers
    @client.puts output
  end

  def output_hello
    output = "<pre>Hello, World! (#{@hello_counter})</pre>"
    @output_length = output.length
    @client.puts headers
    @client.puts output
  end

  def date_now
    Date.today.strftime('%A, %B %e, %Y')
  end

  def time_now
    Time.now.strftime('%l:%M%p')
  end

  def output_date
    output = "<pre>#{time_now} on #{date_now}</pre>"
    @output_length = output.length
    @client.puts headers
    @client.puts output
  end

  def output_shutdown
    shutdown = "Total Requests: #{@total_requests}"
    @output_length = shutdown.length
    @client.puts headers
    @client.puts shutdown
    @closed = true
  end

  def headers
    ['http/1.1 200 ok',
     "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
     'server: ruby',
     'content-type: text/html; charset=iso-8859-1',
     "content-length: #{@output_length}\r\n\r\n"].join("\r\n")
  end

  def word_search
    @word = @path.split('?')[1].split('=')[1]
    search_dictionary
  end

  def search_dictionary
    dictionary = File.read('/usr/share/dict/words')
    if dictionary.include?("#{@word}\n")
      output = "#{@word.upcase} is a known word."
    else
      output = "#{@word.upcase} is not a known word."
    end
    @output_length = output.length
    @client.puts headers
    @client.puts output
  end

  def redirect_headers
    '$ curl -I localhost:9292
    HTTP/1.0 302 Found
    Location: http://localhost:9292/game'
  end
end
