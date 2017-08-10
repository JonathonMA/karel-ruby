# Karel for ruby

This is a minimalist implementation of a karel-the-robot system in ruby.

## Usage

```ruby
require_relative "./karel"

Karel.run("world1") do
  move
  move
  turn_left
  move
  move
  if next_to_a_beeper?
    pickup_beeper
  end
end
```
