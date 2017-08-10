class Map
  def initialize(str)
    @rows = []
    @beepers = []
    str.each_line.with_index do |line, y|
      @rows[y] = []
      line.strip.each_char.with_index do |char, x|
        @rows[y][x] = tile_at(char, x, y)
      end
    end
  end

  attr_reader :robot_x, :robot_y, :robot_facing

  def to_s
    buf = @rows.map do |row|
      row.map do |tile|
        case tile
        when :wall
          "▒"
        when :floor
          "."
        else
          raise "Unknown map tile: #{tile}"
        end
      end
    end

    # TODO: animate beepers by alternating character
    @beepers.each do |(x, y)|
      buf[y][x] = "o"
    end

    buf[@robot_y][@robot_x] = robot_char

    buf.map do |row|
      row.join
    end.join("\n")
  end

  RobotRanIntoWall = Class.new(StandardError)

  def clear?(dir)
    next_x, next_y = one_direction_from(@robot_x, @robot_y, derived_facing(dir))

    not wall?(next_x, next_y)
  end

  def move_robot
    next_x, next_y = one_direction_from(@robot_x, @robot_y, @robot_facing)

    if wall?(next_x, next_y)
      raise RobotRanIntoWall, "(#{next_x}, #{next_y})"
    end

    @robot_x = next_x
    @robot_y = next_y
  end

  def one_direction_from(x, y, facing)
    next_x = x + dx(facing)
    next_y = y + dy(facing)

    return next_x, next_y
  end

  DIRECTIONS = %i(
    north
    west
    south
    east
  )

  def turn_left
    @robot_facing = relative_facing(1)
  end

  private def relative_facing(left_turns)
    DIRECTIONS[(DIRECTIONS.index(@robot_facing) + left_turns) % DIRECTIONS.size]
  end

  RobotNotOnBeeper = Class.new(StandardError)

  def pickup_beeper
    remove_beeper_at(@robot_x, @robot_y)
  end

  def put_beeper
    @beepers << [@robot_x, @robot_y]
  end

  def robot_next_to_beeper?
    @beepers.any? do |(bx, by)|
      @robot_x == bx && @robot_y == by
    end
  end

  def facing?(cardinal)
    @robot_facing == cardinal
  end

  private

  def remove_beeper_at(rx, ry)
    beeper_i = @beepers.index do |(bx, by)|
      rx == bx && ry == by
    end

    if beeper_i == nil
      raise RobotNotOnBeeper, "(#{rx}, #{ry})"
    end

    @beepers.delete_at(beeper_i)
  end

  TURNS_TO_FACE = {
    front: 0,
    left: 1,
    back: 2,
    right: 3,
  }

  def derived_facing(rdir)
    relative_facing(TURNS_TO_FACE.fetch(rdir))
  end

  def dx(facing)
    case facing
    when :east
      1
    when :west
      -1
    else
      0
    end
  end

  def dy(facing)
    case facing
    when :south
      1
    when :north
      -1
    else
      0
    end
  end

  def wall?(x, y)
    @rows[y][x] != :floor
  end

  def robot_char
    case @robot_facing
    when :north
      "↑"
    when :east
      "→"
    when :south
      "↓"
    when :west
      "←"
    else
      raise "Unknown robot facing: #{@robot_facing}"
    end
  end

  def robot_at(char, x, y)
    raise "there can be only one (robot)" if @robot_x

    @robot_x = x
    @robot_y = y

    @robot_facing =
      case char
      when "N"
        :north
      when "S"
        :south
      when "E"
        :east
      when "W"
        :west
      end
  end

  def beeper_at(x, y)
    @beepers << [x, y]
  end

  def tile_at(char, x, y)
    case char
    when "#"
      :wall
    when "."
      :floor
    when "o"
      beeper_at(x, y)
      :floor
    when "N", "S", "E", "W"
      robot_at(char, x, y)
      :floor
    else
      raise "Unknown map character: #{char}"
    end
  end
end

class World
  def initialize(str)
    @str = str
  end

  def map
    Map.new(@str)
  end
end

module RobotPredicates
  %i(front left right back).each do |direction|
    clear_method = :"#{direction}_clear?"
    blocked_method = :"#{direction}_blocked?"

    define_method(clear_method) do
      clear?(direction)
    end

    define_method(blocked_method) do
      not clear?(direction)
    end
  end

  def next_to_a_beeper?
    @map.robot_next_to_beeper?
  end

  def not_next_to_a_beeper?
    not next_to_a_beeper?
  end

  def any_beepers_in_beeper_bag?
    @beeper_bag > 0
  end

  def no_beepers_in_beeper_bag?
    not any_beepers_in_beeper_bag?
  end

  %i(north east south west).each do |direction|
    facing_method = :"facing_#{direction}?"
    not_facing_method = :"not_facing_#{direction}?"

    define_method(facing_method) do
      facing?(direction)
    end

    define_method(not_facing_method) do
      not facing?(direction)
    end
  end
end

class Robot
  def initialize(map)
    @map = map
    @beeper_bag = 0
  end

  include RobotPredicates

  def facing?(direction)
    @map.facing?(direction)
  end

  def clear?(direction)
    @map.clear?(direction)
  end

  def move
    @map.move_robot
  end

  def turn_left
    @map.turn_left
  end

  def pickup_beeper
    @map.pickup_beeper
    @beeper_bag += 1
  end

  NoBeepersInBag = Class.new(StandardError)

  def put_beeper
    if @beeper_bag <= 0
      raise NoBeepersInBag
    end
    @map.put_beeper
  end
end

class Runner
  def initialize(world, program)
    @world = world
    @program = program
  end

  def call
    @map = @world.map
    draw!
    @robot = Robot.new(@map)
    instance_eval(&@program)
    puts
    puts "PROGRAM COMPLETE"
  end

  DELAY = 0.1

  def draw!
    @clear ||= %x(tput clear)
    puts @clear
    puts @map
    sleep DELAY
  end

  def move
    @robot.move
    draw!
  end

  def turn_left
    @robot.turn_left
    draw!
  end

  def pickup_beeper
    @robot.pickup_beeper
  end

  def put_beeper
    @robot.put_beeper
  end

  PREDICATES = %i(
    front_clear?
    front_blocked?
    left_clear?
    left_blocked?
    right_clear?
    right_blocked?
    back_clear?
    back_blocked?
    next_to_a_beeper?
    not_next_to_a_beeper?
    any_beepers_in_beeper_bag?
    no_beepers_in_beeper_bag?
    facing_north?
    facing_south?
    facing_east?
    facing_west?
    not_facing_north?
    not_facing_south?
    not_facing_east?
    not_facing_west?
  )

  PREDICATES.each do |predicate|
    define_method(predicate) do
      @robot.public_send(predicate)
    end
  end
end

module Karel
  module_function def run(world, &program)
    world_str = IO.read("worlds/#{world}.txt")
    world = World.new(world_str)

    runner = Runner.new(world, program)
    runner.call
  end
end
