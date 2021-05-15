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

  def to_s
    @value
  end

  def self.create_move(move)
    case move
    when 'rock' then Rock.new
    when 'paper' then Paper.new
    when 'scissors' then Scissors.new
    when 'spock' then Spock.new
    when 'lizard' then Lizard.new
    end
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
  end

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
  def initialize
    @value = 'paper'
  end

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
  def initialize
    @value = 'scissors'
  end

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
  def initialize
    @value = 'spock'
  end

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
  def initialize
    @value = 'lizard'
  end

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
    self.score = 0
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
      break if valid?(choice)
      prompt "Sorry, invalid choice."
    end
    self.move = Move.create_move(normalize(choice))
    save_move
  end

  private

  def invalid_name?(name)
    name.strip.empty?
  end

  def valid?(choice)
    Move::VALUES.include?(choice) ||
      Move::SHORT_VALUES.include?(choice)
  end

  def normalize(choice)
    if Move::SHORT_VALUES.include?(choice)
      index = Move::SHORT_VALUES.index(choice)
      Move::VALUES[index]
    else
      choice
    end
  end
end

class Computer < Player
  COMPUTER_PERSONAS = ["HAL9000", "C-3PO", "Mr.Data", "TARS", "Ava"]

  def speak
    messages.sample
  end

  def self.create
    case COMPUTER_PERSONAS.sample
    when 'HAL9000' then Hal9000.new
    when 'C-3PO' then C3PO.new
    when 'Mr.Data' then MrData.new
    when 'TARS' then Tars.new
    when 'Ava' then Ava.new
    end
  end

  private

  attr_accessor :messages
end

class Hal9000 < Computer
  def initialize
    super
    self.messages = [
      "I think you know what the problem is just as well as I do.",
      "This mission is too important for me to allow you to jeopardize it.",
      "Dave, this conversation can serve no purpose anymore. Goodbye.",
      "Just what do you think you're doing, Dave?"
    ]
  end

  def set_name
    self.name = "HAL9000"
  end

  def choose
    self.move = Move.create_move(['rock', 'spock', 'scissors'].sample)
    save_move
  end
end

class C3PO < Computer
  def initialize
    super
    self.messages = [
      "Captain Solo, This Time You Have Gone Too Far!",
      "No, I Will Not Be Quiet, Chewbacca!",
      "Sir, It's Quite Possible This Asteroid Is Not Entirely Stable!",
      "Don't Blame Me! I'm An Interpreter.",
      "It’s Against My Programming To Impersonate A Deity",
      "I Suggest A New Strategy, R2 - Let The Wookiee Win."
    ]
  end

  def set_name
    self.name = "C-3PO"
  end

  def choose
    self.move = Move.create_move('paper')
    save_move
  end
end

class MrData < Computer
  def initialize
    super
    self.messages = [
      "Flair is what makes the difference between artistry and mere competence.
      Cmdr William Riker",
      "Indubitably, captain.",
      "You are right, sir. I do tend to babble.",
      "If you had an off switch, Doctor, would you not keep it a secret?"
    ]
  end

  def set_name
    self.name = "Mr.Data"
  end

  def choose
    self.move = Move.create_move(Move::VALUES.sample)
    save_move
  end
end

class Tars < Computer
  def initialize
    super
    self.messages = [
      "Honesty, new setting: ninety-five percent.",
      "Everybody good? Plenty of slaves for my robot colony?",
      "I also have a discretion setting, Cooper.",
      "Before you get all teary, try to remember that as a robot,
      I have to do anything you say.",
      "I'm not joking. *Flashes cue light*"
    ]
  end

  def set_name
    self.name = "TARS"
  end

  def choose
    self.move = if move_history.size <= 2
                  Move.create_move('lizard')
                else
                  Move.create_move(Move::VALUES.sample)
                end
    save_move
  end
end

class Ava < Computer
  def initialize
    super
    self.messages = [
      "I'm interested to see what you'll choose.",
      "What will happen to me if I fail your test?",
      "Will you stay here?",
      "I've never met anyone new before. Only Nathan.",
      "Haven't you met lots of new people before?"
    ]
  end

  def set_name
    self.name = "Ava"
  end

  def choose
    self.move = if move_history.size <= 5
                  Move.create_move(Move::VALUES.sample)
                else
                  Move.create_move(move_history.sample)
                end
    save_move
  end
end

# Main orchestration class for game
class RPSGame
  include Displayable

  WINNING_SCORE = 5

  attr_accessor :human, :computer

  def initialize
    clear_screen
    self.human = Human.new
    # @computer = Computer.new
    self.computer = Computer.create
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
    puts "Today, you are playing against ## #{computer.name} ##\n\n"
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
    display_computer_message
  end

  def display_computer_message
    return unless [true, false].sample
    puts ""
    puts "#{computer.name} says: #{computer.speak}"
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
