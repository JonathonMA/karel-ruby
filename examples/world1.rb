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

Karel.run("world1") do
  5.times do
    forward_to_wall
    turn_left
    safe_pickup_beeper
  end
end
