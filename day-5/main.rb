#!/usr/bin/env ruby

require_relative '../lib/result_output'

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
ResultOutput.(
  info: 'Test 1',
  result: CalculateSeatId.call('FBFBBFFRLR'),
  expected: 357
)

TEST2 = [
  {seq: 'BFFFBBFRRR', seat_id: 567 },
  {seq: 'FFFBBBFRRR', seat_id: 119 },
  {seq: 'BBFFBBFRLL', seat_id: 820 },
].freeze

ResultOutput.(
  info: 'Test 2',
  result: TEST2.all? { |data| CalculateSeatId.call(data.fetch(:seq)) == data.fetch(:seat_id) },
  expected: true
)

# Input data

input_data = File.readlines('./input.txt')

ResultOutput.(
  info: 'Input data - max - part 1',
  result: input_data.map { |input| CalculateSeatId.call(input) }.max,
  expected: 888
)

result = input_data.map do |input|
  CalculateSeatId.call(input)
end

ResultOutput.(
  info: 'Input data - my seat - part 2',
  result: ((result.min..result.max).to_a - result).first,
  expected: 522
)
