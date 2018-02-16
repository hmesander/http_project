module Game
  def begin_game
    if @answer.nil?
      @answer = rand(0..100)
      output = 'Good luck!'
      @output_length = output.length
      @client.puts headers
      @client.puts output
    else
      response_code_403
    end
  end

  def store_guess
    body = @client.readpartial(@content_length)
    guess = body.split("\n")[3].to_i
    @guesses << guess
    if @answer.nil?
      begin_game
      @client.puts redirect_header_301
    else
      @client.puts redirect_header_302
    end
  end

  def guess_stats
    @guesses.map do |guess|
      if guess > @answer
        "#{guess} - too high!"
      elsif guess < @answer
        "#{guess} - too low!"
      elsif guess == @answer
        "#{guess} - correct!"
      end
    end
  end

  def game_stats
    output1 = "You have taken #{@guesses.count} guesses.\n"
    output2 = "Guesses taken so far:\n#{guess_stats.join("\n")}"
    @output_length = (output1 + output2).length
    @client.puts headers
    @client.puts output1 + output2
  end

  def redirect_header_302
    "HTTP/1.0 302 Found\r\nLocation: http://localhost:9292/game\r\n\r\n\r\n"
  end

  def redirect_header_301
    "HTTP/1.1 301 Moved Permanently\r\nLocation: http://localhost:9292/game\r\n\r\n\r\n"
  end

  def response_code_403
    output = '403 Forbidden'
    @client.puts ['http/1.0 403 Forbidden',
                  "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                  'server: ruby',
                  'content-type: text/html; charset=iso-8859-1',
                  "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @client.puts output
  end

  def response_code_404
    output = '404 Not Found'
    @client.puts ['http/1.0 404 Not Found',
                  "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                  'server: ruby',
                  'content-type: text/html; charset=iso-8859-1',
                  "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @client.puts output
  end

  def response_code_500
    output = '500 Internal Server Error'
    @client.puts ['http/1.0 500 Internal Server Error',
                  "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
                  'server: ruby',
                  'content-type: text/html; charset=iso-8859-1',
                  "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @client.puts output
  end
end
