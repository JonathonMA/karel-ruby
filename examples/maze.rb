require_relative "../karel"

def forward_to_wall
  while front_clear?
    move
  end
end

def safe_pickup_beeper
  if next_to_a_beeper?
    pickup_beeper
  end
end

def move_and_pickup
  move
  safe_pickup_beeper
end

def turn_right
  3.times { turn_left }
end

def turn_around
  2.times { turn_left }
end

def follow_wall
  while left_blocked? and front_clear?
    move_and_pickup
  end

  if left_clear?
    turn_left
  elsif right_clear?
    turn_right
  else
    turn_around
  end

  move_and_pickup
end

def follow_right_wall
  if right_clear?
    turn_right
    move_and_pickup
  elsif front_clear?
    move_and_pickup
  else
    turn_left
  end
end

def follow_left_wall
  if left_clear?
    turn_left
    move_and_pickup
  elsif front_clear?
    move_and_pickup
  else
    turn_right
  end
end

Karel.run("maze") do
  forward_to_wall
  3.times { turn_left }

  loop do
    follow_left_wall
  end
end
