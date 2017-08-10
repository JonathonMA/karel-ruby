require_relative "../karel"

def turn_around
  2.times { turn_left }
end

def dance
  begin
    move
    turn_around
    move
    move
    turn_around
    move
  end
end

Karel.run("world1") do
  5.times do
    dance
  end
end
