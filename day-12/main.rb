#!/usr/bin/env ruby

Dir["../lib/*.rb"].each {|file| require file }
ReadInput.(12)

class Klass
  include DeepCopy

  attr_reader :data, :heading, :position, :waypoint

  def initialize(data)
    @waypoint = [10, 1]
    @position = [0, 0]
    @heading = 'E'
    @data = data
  end

  ### PART 1

  def find_heading(value)
    case (value % 360)
    when 0 then 'N'
    when 90 then 'E'
    when 180 then 'S'
    when 270 then 'W'
    end
  end

  def find_value(heading)
    case heading
    when 'N' then 0
    when 'E' then 90
    when 'S' then 180
    when 'W' then 270
    else
      'N'
    end
  end

  def turn(direction, distance)
    hval = find_value(heading)
    case direction
    when 'R'
      @heading = find_heading(hval + distance)
    when 'L'
      @heading = find_heading(hval - distance)
    end
  end

  def update_position(index, method, arg)
    @position[index] = @position[index].send(method, arg)
  end

  def run
    data.each do |command|
      command = command.gsub('F', heading) if %(F).include? command[0, 1]

      head = command[0, 1]
      distance = command[1..].to_i

      case head
      when 'N'
        update_position(0, :+, distance)
      when 'S'
        update_position(0, :-, distance)
      when 'E'
        update_position(1, :+, distance)
      when 'W'
        update_position(1, :-, distance)
      else
        turn(head, distance)
      end
    end

    position.map { |pos| pos.abs }.sum
  end

  ### PART 2

  def turn_wayp(direction, degrees)
    turn_right = lambda do |(r, c), deg|
      return [r, c] if deg.zero?

      turn_right.call([c, -r], deg - 90)
    end

    turn_left = lambda do |(r, c), deg|
      return [r, c] if deg.zero?

      turn_left.call([-c, r], deg - 90)
    end

    case direction
    when 'R' then @waypoint = turn_right.call(waypoint, degrees)
    when 'L' then @waypoint = turn_left.call(waypoint, degrees)
    end
  end

  def update_waypoint(index, method, arg)
    @waypoint[index] = @waypoint[index].send(method, arg)
  end

  def forward(distance)
    r = @position.first + waypoint.first * distance
    c = @position.last + waypoint.last * distance
    @position = [r, c]
  end

  def run_part2
    data.each do |command|
      head = command[0, 1]
      distance = command[1..].to_i

      case head
      when 'F'
        forward(distance)
      when 'N'
        update_waypoint(1, :+, distance)
      when 'S'
        update_waypoint(1, :-, distance)
      when 'E'
        update_waypoint(0, :+, distance)
      when 'W'
        update_waypoint(0, :-, distance)
      else
        turn_wayp(head, distance)
      end
    end

    position.map(&:abs).sum
  end
end

ResultOutput.(
  info: 'Demo',
  expected: 25
) { Klass.new(ReadInput.sample).run }

ResultOutput.(
  info: 'Part 1',
  expected: 1441
) { Klass.new(ReadInput.input).run }

ResultOutput.(
  info: 'Demo',
  expected: 286
) { Klass.new(ReadInput.sample).run_part2 }

ResultOutput.(
  info: 'Part 2',
  expected: 61616
) { Klass.new(ReadInput.input).run_part2 }
