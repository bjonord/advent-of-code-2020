#!/usr/bin/env ruby

class PositionFinder
  attr_reader :range, :left, :right
  attr_accessor :current

  def self.process(range, sequence)
    new(range).process(sequence)
  end

  def initialize(range)
    @range = range.to_a
  end

  def process(sequence, data: range)
    return data.last if sequence.empty?

    head, *tail = *sequence

    process(
      tail,
      data: path(head, *extract_sections(data))
    )
  end

  def extract_sections(data)
    data.each_slice((data.size / 2.0).round)
  end

  def path(head, left, right)
    if %w[F L].include? head
      left
    else
      right
    end
  end
end

class Row < PositionFinder
  def self.process(sequence)
    super (0..127), sequence
  end
end

class Column < PositionFinder
  def self.process(sequence)
    super (0..7), sequence
  end
end

module CalculateSeatId
  module_function

  def call(sequence)
    @sequence = sequence.gsub("\n", '')
    sliced_input = slice_it
    Row.process(sliced_input.first) * 8 + Column.process(sliced_input.last)
  end

  def slice_it
    [[0, 7], [7, 9]].map { |slice| @sequence.send(:[], *slice).split('') }
  end
end

# Test
puts 'Test 1'
seat_id = CalculateSeatId.call('FBFBBFFRLR')
if seat_id == 357
  puts 'nice'
else
  puts 'uh oh'
  exit 1
end

puts 'Test 2'

TEST2 = [
  {seq: 'BFFFBBFRRR', seat_id: 567 },
  {seq: 'FFFBBBFRRR', seat_id: 119 },
  {seq: 'BBFFBBFRLL', seat_id: 820 },
].freeze

test2 = TEST2.all? { |data|
  CalculateSeatId.call(data.fetch(:seq)) == data.fetch(:seat_id)
}

if test2
  puts 'nice'
else
  puts 'uh oh'
  exit 1
end

# Input data

puts 'Input data'

input = File.readlines('./input.txt')

result = input.map do |input|
  CalculateSeatId.call(input)
end

if result.max == 888
  puts 'nice'
else
  puts 'uh oh'
  exit 1
end

my_seat = (result.min..result.max).to_a - result

if my_seat.first == 522
  puts 'found my seat!'
else
  puts 'uh oh'
  exit 1
end
