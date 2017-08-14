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

## Programming Karel

### Commands / Procedures

A command tells karel to take an action that affects his world:

- `move`
    Moves karel one space in the direction he is facing. If the space is blocked, will cause karel to crash.
- `turn_left`
- `pickup_beeper`
    Moves a beeper from karel's current space to his beeper bag. If there are no beepers present, will cause karel to crash.
- `put_beeper`
    Moves a beeper from karel's beeper bag to his current space. If there are no beepers in his bag, will cause karel to crash.

### Queries / Predicates / Functions

A query allows us to ask questions about karel's world:

- `front_clear?`
- `front_blocked?`
- `left_clear?`
- `left_blocked?`
- `right_clear?`
- `right_blocked?`
- `back_clear?`
- `back_blocked?`
- `next_to_a_beeper?`
- `not_next_to_a_beeper?`
- `any_beepers_in_beeper_bag?`
- `no_beepers_in_beeper_bag?`
- `facing_north?`
- `facing_south?`
- `facing_east?`
- `facing_west?`
- `not_facing_north?`
- `not_facing_south?`
- `not_facing_east?`
- `not_facing_west?`

### Loops

```ruby
while <predicate>
end
```

Move until we're about to hit a wall:

```ruby
while front_clear?
  move
end
```

Turn until we can move:

```ruby
while front_blocked?
  turn_left
end
```

Pick up all the beepers on the current space:

```ruby
while next_to_a_beeper?
  pickup_beeper
end
```

### Defining methods

We can build our own version of the built-in methods using def. Place these *before* the call to `Karel.run`.

```ruby
def about_face
  turn_left
  turn_left
end

Karel.run("world1") do
  about_face
end
```
