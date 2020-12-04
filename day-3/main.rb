#!/usr/bin/env ruby

class PathTravel
  attr_reader :right, :down
  def initialize(right:, down:)
    @right = right
    @down = down
  end
end

class Position
  attr_reader :slope, :right, :down, :bottom

  def initialize(slope, bottom)
    @right = nil
    @down = 0
    @slope = slope
    @bottom = bottom - 1
  end

  def move
    if right.nil?
      @down = 0
      @right = 0
    else
      @down += slope.down
      @right += slope.right
    end
  end

  def at_the_bottom?
    down == bottom
  end
end

class PathRow
  attr_reader :row

  def initialize(row)
    @row = row
  end

  def current_char(position)
    row[(position % row.length)]
  end

  def tree?(position)
    true if current_char(position) == '#'
  end
end

module GlidingThroughTheSnow
  module_function

  def slopes
    [
      PathTravel.new(right: 1, down: 1),
      PathTravel.new(right: 3, down: 1),
      PathTravel.new(right: 5, down: 1),
      PathTravel.new(right: 7, down: 1),
      PathTravel.new(right: 1, down: 2),
    ]
  end

  def first_attempt
    slope = slopes[1]
    position = Position.new(slope, data_map.length)
    trees = data_map.map { |path_row| path_row.tree?(position.move) }.compact.length

    if trees != 209
      puts "not correct"
      puts trees
      exit 1
    else
      puts "all good"
      puts trees
    end
  end

  def second_attempt
    trees = slopes.map do |slope|
      foundTrees = []
      position = Position.new(slope, data_map.length)

      until position.at_the_bottom? do
        position.move
        foundTrees << data_map[position.down].tree?(position.right)
      end

      foundTrees.compact.length
    end.reduce(:*)

    if trees != 1574890240
      puts "not correct"
      puts trees
      exit 1
    else
      puts "all good"
      puts trees
    end
  end

  def data_map
    @data_map ||= input.map { |row| PathRow.new row.strip }
  end

  def input
    @input ||= File.readlines('./input.txt')
  end
end

puts "--------------"
puts "First attempt:"
puts "--------------"
GlidingThroughTheSnow.first_attempt
puts "--------------"

puts "--------------"
puts "Second attempt:"
puts "--------------"
GlidingThroughTheSnow.second_attempt
puts "--------------"
