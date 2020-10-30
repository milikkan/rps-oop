module Displayable
  def clear_screen
    system("clear") || system("cls")
  end

  def prompt(message)
    puts "=> #{message}"
  end

  def display_banner(title)
    line(title, 3)
    puts "## #{title.upcase} ##"
    line(title, 3)
  end

  private

  def line(str, gap)
    puts '#' * (str.size + gap * 2)
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']
  SHORT_VALUES = ['r', 'p', 'sc', 'sp', 'l']

  def initialize(value)
    @value = value
  end

  def to_s
    @value
  end
end

class Rock < Move
  def >(other_move)
    ['scissors', 'lizard'].include?(other_move.to_s)
  end

  def winning_message(loser_move)
    case loser_move.to_s
    when 'lizard'   then 'ROCK crushes LIZARD'
    when 'scissors' then 'ROCK crushes SCISSORS'
    end
  end
end

class Paper < Move
  def >(other_move)
    ['rock', 'spock'].include?(other_move.to_s)
  end

  def winning_message(loser_move)
    case loser_move.to_s
    when 'rock'  then 'PAPER covers ROCK'
    when 'spock' then 'PAPER disproves SPOCK'
    end
  end
end

class Scissors < Move
  def >(other_move)
    ['paper', 'lizard'].include?(other_move.to_s)
  end

  def winning_message(loser_move)
    case loser_move.to_s
    when 'paper'  then 'SCISSORS cuts PAPER'
    when 'lizard' then 'SCISSORS decapitates LIZARD'
    end
  end
end

class Spock < Move
  def >(other_move)
    ['scissors', 'rock'].include?(other_move.to_s)
  end

  def winning_message(loser_move)
    case loser_move.to_s
    when 'scissors' then 'SPOCK smashes SCISSORS'
    when 'rock'     then 'SPOCK vaporizes ROCK'
    end
  end
end

class Lizard < Move
  def >(other_move)
    ['paper', 'spock'].include?(other_move.to_s)
  end

  def winning_message(loser_move)
    case loser_move.to_s
    when 'paper' then 'LIZARD eats PAPER'
    when 'spock' then 'LIZARD poisons SPOCK'
    end
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
    @move_history = []
  end

  def save_move
    @move_history << move
  end

  def move_history
    @move_history.map(&:to_s)
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
    self.move = RPSGame::POOL_OF_MOVES[normalize_choice(choice)]
    save_move
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
    self.move = RPSGame::POOL_OF_MOVES[Move::VALUES.sample]
    save_move
  end
end

# Main orchestration class for game
class RPSGame
  include Displayable

  POOL_OF_MOVES = {
    'rock' => Rock.new('rock'),
    'paper' => Paper.new('paper'),
    'scissors' => Scissors.new('scissors'),
    'spock' => Spock.new('spock'),
    'lizard' => Lizard.new('lizard')
  }

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
      display_move_history
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
    refresh_scoreboard
    display_selection_menu
    human.choose
    computer.choose
    display_choices
    winner = determine_round_winner
    update_score(winner)
    display_round_result(winner)
    prompt_for_next_round unless game_won?
  end

  def refresh_scoreboard
    clear_screen
    display_banner("rock-paper-scissors")
    display_scores
  end

  def display_scores
    puts ""
    puts "================================"
    puts "           SCOREBOARD"
    puts "   (Player reaching #{WINNING_SCORE} wins)"
    puts ""
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
      refresh_scoreboard
      display_choices
      display_winning_message(winner)
      display_round_winner(winner)
    end
  end

  def display_round_winner(round_winner, last=false)
    puts ""
    puts "#{round_winner.name} won #{last ? 'the last' : 'this'} round!"
  end

  def display_winning_message(winner)
    loser = winner == human ? computer : human
    message = winner.move.winning_message(loser.move)
    puts "===>  #{message}   <==="
  end

  def tie?
    human.move.to_s == computer.move.to_s
  end

  def determine_round_winner
    human.move > computer.move ? human : computer
  end

  def update_score(winner)
    winner.score += 1 unless tie?
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
    refresh_scoreboard
    display_choices
    last_round_winner = determine_round_winner
    display_winning_message(last_round_winner)
    display_round_winner(last_round_winner, true)
    game_winner = human.score == WINNING_SCORE ? human : computer
    display_game_winner(game_winner)
  end

  def display_game_winner(game_winner)
    puts ""
    puts "================================"
    puts "           GAME OVER"
    puts ""
    puts "     #{game_winner.name} won the game! "
    puts "================================"
  end

  def display_move_history
    puts ""
    puts "#{human.name}'s moves so far: #{human.move_history.join(' - ')}"
    puts "#{computer.name}'s moves so far: #{computer.move_history.join(' - ')}"
    puts ""
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (yes/y or no/n)"
      answer = gets.chomp.strip.downcase
      break if %w(yes y no n).include?(answer)
      puts "Invalid choice..."
    end
    answer == 'y' || answer == 'yes'
  end

  def display_goodbye_message
    puts ""
    puts "Thanks for playing, good bye!"
  end
end

RPSGame.new.play

# keeping score             : DONE
# add spock and lizard      : DONE
# add a class for each moves: DONE
# keep track of move history: DONE
# add computer personalities:
# add shortcuts for choices : DONE
# add winning messages      : DONE
# UI improvements           :
