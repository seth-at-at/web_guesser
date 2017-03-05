require 'sinatra'
# require 'sinatra/reloader'

class WebGuesser
  attr_reader :answer, :counter

  def initialize
    @answer = rand(100)
    @counter = 0
  end

  def responses
  {
    too_high: "Your guess is too high", way_too_high: "Your guess is way too high",
    too_low: "Your guess is too low", way_too_low: "Your guess is way too low",
    correct: "Correct! the number is #{answer}", 
    welcome: "Please enter a guess",
    cheat: "The correct answer was #{answer}"
  }
  end

  def answer_within_one?(guess)
    return "https://media.giphy.com/media/KBtNR7MkrO5UY/giphy.gif" if guess.to_i == 0 && guess != "cheat"
    return "https://media.giphy.com/media/7rj2ZgttvgomY/giphy.gif" if guess.to_i == answer
    return "http://i.imgur.com/9sxHPBx.jpg" if (guess.to_i - answer) == 1 || (guess.to_i - answer) == -1
    return "https://m.popkey.co/2420c1/mv5a_f-maxage-0.gif" if guess == "cheat"
  end

  def backgrounds
    {
      way_too_high: "#00ecff", too_high: "#0011ff",
      way_too_low: "#fd00ff", too_low: "#c900ff",
      correct: "#00ff00", welcome: "#ff0000",
      cheat: "000000"
    }
  end


  def give_response(guess = nil)
    @counter += 1

    if @counter > 4
      new_answer
      return "You took too many guesses, the correct answer was #{answer}. Now generating new number!"
    end

    if guess == "cheat"
      new_answer
      return "The correct answer was #{answer}, now generating new number!"
    end
    return responses[:welcome] if guess.nil?
    return responses[:welcome] if guess.to_i == 0 && guess.class != "string"
    return responses[:gif] if (guess.to_i - answer ) == 1
    return responses[:gif] if (guess.to_i - answer ) == -1
    return responses[:way_too_high] if (guess.to_i - answer ) > 20
    return responses[:too_high] if guess.to_i > answer
    return responses[:way_too_low] if (guess.to_i - answer ) < -20
    return responses[:too_low] if guess.to_i < answer
    return responses[:correct] if guess.to_i == answer
  end

  def new_answer
    @answer = rand(100)
    @counter = 0
  end

  def background_color(guess)
    return backgrounds[:cheat] if guess == "cheat"
    return backgrounds[:way_too_high] if (guess.to_i - answer ) > 5
    return backgrounds[:too_high] if guess.to_i > answer
    return backgrounds[:way_too_low] if (guess.to_i - answer ) < -5
    return backgrounds[:too_low] if guess.to_i < answer
    return backgrounds[:correct] if guess.to_i == answer
  end
end

guesser = WebGuesser.new

get '/' do
  guess = params['guess']
  erb :web_guesser_html, :locals => {
        :message => guesser.give_response(guess),
        :background => guesser.background_color(guess),
        :gif => guesser.answer_within_one?(guess)
      }
end