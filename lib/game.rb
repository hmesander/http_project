module Game
  def begin_game
    @answer = rand(0..100)
    output = 'Good luck!'
    @output_length = output.length
    @client.puts headers
    @client.puts output
  end

  def store_guess
    body = @client.readpartial(@content_length)
    guess = body.split('=')[1].to_i
    @guesses << guess
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
end
