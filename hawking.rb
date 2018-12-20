puts
puts "                __STEPHEN_HAWKING:_THE_VIDEO_GAME__"
puts
puts "Mad physicist Stephen Hawking has trapped you in a box of unknown dimensions, with presumed evil intent."
puts "Survive as long as possible by running away from him."
puts "Hawking can be recognised as any of these arrows, depending which direction he is facing:"
puts "<, L, V, \\, >, ¬, ^, F"
puts "He has limited peripheral vision, being unable to rotate his head."
puts
loop do
  puts "Choose a one-character string to represent your player."
  $username = STDIN.gets.chomp
  break if $username.length == 1
end

$turn = []
$game = 0
$compass_options = ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw']

@@gameplay = Proc.new do
  $play_again = nil
  $the_map = Map.new
  # Hawking should be created after the map, to make sure he appears on it.
  $Hawking_bot = Hawking.new
  $the_player = Player.new
  # A new accumulator for the number of turns for the current game:
  $turn.push(0)
  while true
	$Hawking_bot.choose_move
    $the_map.print_the_map
	$the_player.choose_move
	$the_player.do_the_move
	$Hawking_bot.do_the_move
	break if $play_again == ""
  end
end

def print_big_gap
  100.times {puts}
end

def game_over
  print_big_gap
  end_messages = ['Hawking used gravitational lensing to focus deadly laser beams on you.', 'You died of Hawking radiation.', 'Hawking ran you over with his motorized chair.', 'Hawking condensed you into a gravitational singularity.', 'Hawking caught you in the event horizon of his pocket black-hole.', 'Hawking used a mathematical proof to show that you do not exist.']
  puts "Oh no! #{end_messages.sample}"
  puts
  puts "GAME OVER"
  puts
  puts "Turn count: #{$turn[$game]}"
  puts "Game count: #{$game+1}"
  $the_map.print_the_map
  puts
  puts "_" * 20
  $game += 1
  too_many_games = 10
  puts "Type X to quit, or hit return to play again. (Auto-quits after #{too_many_games} games.)"
  $play_again = STDIN.gets.chomp
  if $game > too_many_games || $play_again.downcase == 'x'
    accumulator = 0
	$turn.each do |z|
	  accumulator += z
	end
    puts "Average turns to complete with #{$the_map.x_max} by #{$the_map.y_max} square: #{accumulator.to_f / $game.to_f} over #{$game} games"
	exit
  else
    puts "I'll take that as an enthusiastic yes." if $play_again != ""
	@@gameplay.call
  end
end

class Map

  [:x_min, :x_max, :y_min, :y_max, :left_margin, :wormholes, :star_gaps].each {|z|
    attr_accessor z
  }

  def initialize
    @x_min = 1
	@y_min = 1
    min_size = 5
	max_size = 30
    if ARGV[0].nil? && ARGV[1].nil?
	  @x_max = rand(min_size..max_size)
	  @y_max = rand(min_size..max_size)
	else
	  @x_max = @x_min + ARGV[0].to_i
	  @y_max = @y_min + ARGV[1].to_i
	end
    dimensions = (@x_max-@x_min)*(@y_max-@y_min)
	@wormholes = []
	rand(3..6).times {
	  @wormholes.push([rand(x_min..x_max), rand(y_min..y_max)])
	}
	@star_gaps = []
	(x_min..x_max).each do |x|
	  (y_min..y_max).each do |y|
	    if ((rand(3) <= 1) && (!@wormholes.include? ([x, y]))) && (!@star_gaps.include? ([x, y]))
	      @star_gaps.push([x, y]) unless (x == x_min || x == x_max) || (y == y_min || y == y_max)
	    end
	  end
	end
	# Just for printing:
	@left_margin = 10
  end
  
  def print_horizontal_edge
    print ' ' * @left_margin
	print ' _' * (x_max - x_min)
	puts ' _'
  end
  
  def print_the_map
    print_big_gap
    (y_min..y_max).each do |y|
	   print (' ' * @left_margin)
	  (x_min..x_max).each do |x|
		if [x, y] == $the_player.location
		  print "#{$the_player.appearance} "
		elsif [x, y] == $Hawking_bot.location
		  print "#{$Hawking_bot.appearance} "
		elsif wormholes.include? [x, y]
		  print "@ "
		elsif star_gaps.include? [x, y]
		  print '  '
		else
		  star_types = ['*']
		  50.times {star_types.push('.')}
		  print star_types.sample + ' '
		end
	  end
	  puts
	end
	puts
  end
  
end
$the_map = Map.new

def move(direction, current_loc)
  new_location = []
  if direction.length == 2
    return move(direction[0], location = move(direction[1], current_loc))
  end
  case direction
	when 'n'
      new_location[1] = current_loc[1]-1
      new_location[0] = current_loc[0]
	when 'e'
	  new_location[0] = current_loc[0]+1
	  new_location[1] = current_loc[1]
	when 's'
	  new_location[1] = current_loc[1]+1
      new_location[0] = current_loc[0]
	when 'w'
	  new_location[0] = current_loc[0]-1
      new_location[1] = current_loc[1]
  end
  return new_location
end

def absolute(x)
  return -x if x < 0
  x
end

def distance(loc, destination)
  x_distance = loc[0] - destination[0]
  y_distance = loc[1] - destination[1]
  total = absolute(x_distance) + absolute(y_distance)
  return total
end


def face_a_towards_b(a, b) # where be is a location, not an agent
  scores = {}
  $compass_options.each { |direction|
    scores[direction] = distance(a.location, b) - distance(move(direction, a.location), b)
    scores[direction] = -10 if move(direction, a.location).is_outside_map?
  }
  top_score = scores.sort_by { |k, v| -v }[0][1]
  if scores[compass_dir] == scores.sort_by { |k, v| -v }[0][1]
    # keep facing same way
  else
    a.compass_dir = scores.sort_by { |k, v| -v }[0][0]
  end
end

def be_sucked_down_wormhole(agent)
  other_wormholes = []
  $the_map.wormholes.each { |hole|
    other_wormholes.push(hole) unless hole == agent.location
  }
  destination = other_wormholes.sample
  until agent.location == destination
    face_a_towards_b(agent, destination)
    move_option = move(agent.compass_dir, agent.location)
 	unless move_option.is_outside_map?
      agent.location = move_option
	  a = 0
	  until a == 1000000 do
	    a += 1
	  end
	  $the_map.print_the_map
	end
  end
end

class Array
  def is_outside_map?
	if self[0] < $the_map.x_min || self[0] > $the_map.x_max || self[1] < $the_map.y_min || self[1] > $the_map.y_max
	  return true
	else
	  return false
	end
  end
end

class Hawking

  [:location, :inventory, :compass_dir, :appearance, :found_player, :new_location].each {|z|
    attr_accessor z
  }

  def initialize
    # location includes + 1 to avoid starting on top of the player.
    @location = [rand(($the_map.x_min+1)..$the_map.x_max), rand(($the_map.y_min+1)..$the_map.y_max)]
	@inventory = ['A pocket black-hole']
	@compass_dir = 'n'
	@appearance = '^'
	@found_player = false
  end
  
  def rotate_compass(rotation)
    # Find the index of the current compass_dir within compass_options.
    index = $compass_options.index(@compass_dir)
    if index+rotation >= $compass_options.length
	  @compass_dir = $compass_options[0]
	elsif index+rotation < 0
	  @compass_dir = $compass_options[-1]
	else
	  @compass_dir = $compass_options[index+rotation]
	end
  end
  
  def match_appearance_to_compass_direction
	case @compass_dir
	when 'n'
	  @appearance = '^'
	when 's'
	  @appearance = 'V'
	when 'e'
	  @appearance = '>'
	when 'w'
	  @appearance = '<'
	when 'ne'
	  @appearance = '¬'
	when 'nw'
	  @appearance = 'F'
	when 'sw'
	  @appearance = 'L'
	when 'ne'
	  @appearance = '7'
	when 'se'
	  @appearance = '\\'
	end
  end
  
  def recursively_check_spaces_to_side(loc)
	#To avoid having a n^3 recursion time, so as to instead just have n^2, I check the one space directly in front separately, in can_see_player?.

	if found_player == true
	  return true
	  puts "already found"
	end

	# base case
	if loc == $the_player.location
	  puts "I FOUND YOU!!!"
	  found_player = true # Added because it turned out the program continued to recur even after locating the player (not indefinitely).
	  return true
	  
	# otherwise, check the spaces in front and 1 to either side
	else
	  $checked.push(loc) unless $checked.include? loc # the unless bit is to save time in printing the map.
	  #rotate_compass does what it says on the tin, so you have to make sure to leave it where it was originally, else
	  # Hawking will check the entire observable universe within the map. Without end.
	  rotate_compass(-1)
	  to_Hawks_left = move(compass_dir, loc)
	  
	  2.times {rotate_compass(1)}
	  to_Hawks_right = move(compass_dir, loc)
	 
	  rotate_compass(-1)
	  
      if (to_Hawks_left.is_outside_map? == false) && recursively_check_spaces_to_side(to_Hawks_left) == true
	    return true
		puts "passed up"
	  elsif (to_Hawks_right.is_outside_map? == false) && recursively_check_spaces_to_side(to_Hawks_right) == true
	    return true
		puts "passed up"
	  else
	    # Do not return 'false' preemptively here!
	  end
    end
	return false
  end
  
  def can_see_player?
    if distance(location, $the_player.location) >= distance((move(compass_dir, location)), $the_player.location)
      return true
    else
      return false
    end	  
  end
  
  def choose_move
	@new_location = [-1, -1]	
	while new_location.is_outside_map?
	  if $Hawking_bot.can_see_player? == false
	    rotate_compass(rand(-1..1))
	  elsif move(compass_dir, location).is_outside_map?
	    until !move(compass_dir, location).is_outside_map? && $Hawking_bot.can_see_player?
		  rotate_compass(rand(-1..1))
		end
	  else
	    face_a_towards_b($Hawking_bot, $the_player.location)
	  end
	  @new_location = move(compass_dir, location)
	end
  end	

  def do_the_move
	@location = new_location
	match_appearance_to_compass_direction
	if $the_map.wormholes.include? location
	  be_sucked_down_wormhole(self)
	end
	if location == $the_player.location
	  $the_player.appearance = '+'
	  game_over
	end
  end
end
$Hawking_bot = Hawking.new

class Player

  [:location, :inventory, :compass_dir, :appearance].each {|z|
    attr_accessor z
  }

  def initialize
    @location = [$the_map.x_min, $the_map.y_min]
	@inventory = ['A time machine']
	@compass_dir = ['n']
	@appearance = $username
  end
  
  def choose_move
    dir = 0
    loop do
	puts "Which direction would you like to move? N, S, E, W, or diagonally."
      dir = STDIN.gets.chomp.downcase
	  if !$compass_options.include? dir
	    puts "Well, that wasn't one of the options."
	  elsif move(dir, location).is_outside_map?
	    puts "You cannot leave the map."
	  elsif move(dir, location) == $Hawking_bot.location
	    @location = move(dir, location)
		@appearance = '+'
		game_over
	  else
	    break
	  end
    end
	@compass_dir = dir
  end
	
  def do_the_move
	@location = move(compass_dir, location)
	if $the_map.wormholes.include? location
	  be_sucked_down_wormhole(self)
	end
	$turn[$game] += 1
  end
end
$the_player = Player.new

loop do
  @@gameplay.call 
end