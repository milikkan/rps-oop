module Displayable
  def clear_screen
    system("clear") || system("cls")
  end

  def prompt(message)
    puts "=> #{message}"
  end

  def display_banner(title)
    puts '#' * (title.size + 6)
    puts "## #{title.upcase} ##"
    puts '#' * (title.size + 6)
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']
  SHORT_VALUES = ['r', 'p', 'sc', 'sp', 'l']

  WINNING_RULES = {
    'rock' => ['scissors', 'lizard'],
    'paper' => ['rock', 'spock'],
    'scissors' => ['paper', 'lizard'],
    'spock' => ['scissors', 'rock'],
    'lizard' => ['paper', 'spock']
  }

  def initialize(value)
    @value = value
  end

  def >(other_move)
    WINNING_RULES[to_s].include?(other_move.to_s)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end
end

class Human < Player
  include Displayable

  def set_name
    n = ""
    loop do
      prompt "What's your name?"
      n = gets.chomp
      break unless invalid_name?(n)
      prompt "Sorry, you must enter a value.\n\n"
    end
    self.name = n.strip
  end

  def choose
    choice = nil
    loop do
      prompt "Choose one, you also can type abbreviations:"
      choice = gets.chomp.downcase.strip
      break if valid_choice?(choice)
      prompt "Sorry, invalid choice."
    end
    self.move = Move.new(normalize_choice(choice))
  end

  private

  def invalid_name?(name)
    name.strip.empty?
  end

  def valid_choice?(choice)
    Move::VALUES.include?(choice) ||
      Move::SHORT_VALUES.include?(choice)
  end

  def normalize_choice(choice)
    if Move::SHORT_VALUES.include?(choice)
      index = Move::SHORT_VALUES.index(choice)
      Move::VALUES[index]
    else
      choice
    end
  end
end

class Computer < Player
  def set_name
    self.name = ["R2D2", "Hal", "Chappie", "Sonny", "Number 5"].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

# Main orchestration class for game
class RPSGame
  include Displayable

  WINNING_SCORE = 2

  attr_accessor :human, :computer

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
  end

  def play
    display_welcome_message
    loop do
      reset_scores
      play_round until game_won?
      display_game_result
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "\n\nWelcome to Rock, Paper, Scissors, #{human.name}!"
    puts "Today, your are playing against ## #{computer.name} ##\n\n"
    puts "Press any key to start the game..."
    gets
  end

  def reset_scores
    human.score = 0
    computer.score = 0
  end

  def play_round
    update_scores
    display_selection_menu
    human.choose
    computer.choose
    display_choices
    winner = determine_round_winner
    winner.score += 1 unless tie?
    display_round_result(winner)
    prompt_for_next_round unless game_won?
  end

  def update_scores
    clear_screen
    display_banner("rock-paper-scissors")
    display_scores
  end

  def display_scores
    puts ""
    puts "================================"
    puts "           SCOREBOARD           "
    puts "   (Player reaching #{WINNING_SCORE} wins)"
    puts
    puts "  #{human.name} | #{human.score} - \
     #{computer.score} | #{computer.name}"
    puts "================================"
  end

  def display_selection_menu
    choice_prompt = <<-MSG
      * Rock (r)
      * Paper (p)
      * Scissors (sc)
      * Spock (sp)
      * Lizard (l)
    MSG
    puts choice_prompt
  end

  def display_choices
    puts ""
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_round_result(winner)
    if tie?
      puts "It's a tie!"
    else
      update_scores
      display_choices
      puts "#{winner.name} won this round!"
    end
  end

  def tie?
    human.move.to_s == computer.move.to_s
  end

  def determine_round_winner
    human.move > computer.move ? human : computer
  end

  def prompt_for_next_round
    puts ""
    puts "Hit 'Enter' to play the next round..."
    gets
  end

  def game_won?
    human.score == WINNING_SCORE || computer.score == WINNING_SCORE
  end

  def display_game_result
    update_scores
    display_choices
    puts "#{determine_round_winner.name} won the last round..."
    winner = human.score == WINNING_SCORE ? human : computer
    puts ""
    puts "================================"
    puts "           GAME OVER            "
    puts
    puts "   #{winner.name} won the game! "
    puts "================================"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (yes or no)"
      answer = gets.chomp
      break if %w(y n).include?(answer.downcase)
      puts "Sorry, you must choose y or n."
    end
    answer == 'y'
  end

  def display_goodbye_message
    puts ""
    puts "Thanks for playing, good bye!"
  end
end

RPSGame.new.play

# keeping score             : DONE
# add spock and lizard      : DONE
# add a class for each moves:
# keep track of move history:
# add computer personalities:
# add shortcuts for choices : DONE
# add winning messages      :
# UI improvements           :
