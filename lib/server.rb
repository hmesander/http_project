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
    @guesses        = []
    @answer         = nil
  end

  def process
    closed = false
    until closed
      @client = @tcp_server.accept
      request
      if @path[0..12] == '/word_search?' && @verb == 'GET'
        word_search
      elsif @path == '/start_game' && @verb == 'POST'
        begin_game
      elsif @path == '/game' && @verb == 'GET'
        game_stats
      elsif @path == '/game' && @verb == 'POST'
        parse_post_request
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

  def parse_post_request
    @request_lines = []
    while line = @client.gets and !line.chomp.empty?
      @request_lines << line.chomp
    end
    find_content_length
  end

  def find_content_length
    @request_lines[0] = 'foo: bar'
    split_request = @request_lines.map do |string|
      string.split(': ')
    end
    hash_request = split_request.to_h
    @content_length = hash_request['Content-Length'].to_i
    store_guess
  end

  def store_guess
    body = @client.read(@content_length).to_s
    guess = body.split('=')[1].to_i
    @guesses << guess
    guess_stats
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
    dictionary = File.read('/usr/share/dict/words')
    found = dictionary.include?("#{@word}\n")
    if found
      output = "#{@word.upcase} is a known word."
    else
      output = "#{@word.upcase} is not a known word."
    end
    @output_length = output.length
    @client.puts redirect_headers + headers
    @client.puts output
  end

  def begin_game
    @answer = rand(0..100)
    output = 'Good luck!'
    @output_length = output.length
    @client.puts headers
    @client.puts output
  end

  def game_stats
    output1 = "You have taken #{@guesses.count} guesses.\n"
    output2 = "Guesses taken so far:\n#{guess_stats.join("\n")}"
    @output_length = (output1 + output2).length
    @client.puts headers
    @client.puts output1 + output2
  end

  def guess_stats
    output = @guesses.map do |guess|
      if guess > @answer
        "#{guess} - too high!"
      elsif guess < @answer
        "#{guess} - too low!"
      elsif guess == @answer
        "#{guess} - correct!"
      end
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
