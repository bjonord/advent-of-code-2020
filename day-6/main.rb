#!/usr/bin/env ruby

module ResultOutput
  module_function

  def call(info:, data:, method:, expected:)
    if data.send(method, expected)
      puts "#{info} - \u2705: #{data}"
    else
      puts "#{info} - \u274C: #{data}"
      exit 1
    end
  end
end

DEMO_DATA = <<~DATA.freeze
  abc

  a
  b
  c

  ab
  ac

  a
  a
  a
  a

  b
DATA

INPUT_DATA = File.read('./input.txt')

prepare = ->(data) { data.split("\n\n") }
answers_to_char = ->(group) { group.split.map(&:chars) }
union = ->(answers) { answers.reduce(:|) }
intersect = ->(answers) { answers.reduce(:&) }
sum_it = ->(result) { result.map(&:size).sum }

part1 = ->(data) { data.then(&prepare).map(&answers_to_char).map(&union).then(&sum_it) }
part2 = ->(data) { data.then(&prepare).map(&answers_to_char).map(&intersect).then(&sum_it) }

ResultOutput.(
  info: 'Demo data',
  data: DEMO_DATA.yield_self(&part1),
  method: :==,
  expected: 11
)

ResultOutput.(
  info: 'Input data - union',
  data: INPUT_DATA.yield_self(&part1),
  method: :==,
  expected: 7027
)

ResultOutput.(
  info: 'Input data - intersect',
  data: INPUT_DATA.yield_self(&part2),
  method: :==,
  expected: 3579
)
