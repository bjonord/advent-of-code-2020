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

INPUT_DATA = File.read('./input.txt')

# Playing with lambdas/procs

# Version 1
prepare = ->(data) { data.split("\n\n") }
answers_to_char = ->(group) { group.split.map(&:chars) }
union = ->(answers) { answers.reduce(:|) }
intersect = ->(answers) { answers.reduce(:&) }
sum_it = ->(result) { result.map(&:size).sum }

part1 = ->(data) { data.then(&prepare).map(&answers_to_char).map(&union).then(&sum_it) }
part2 = ->(data) { data.then(&prepare).map(&answers_to_char).map(&intersect).then(&sum_it) }
#######

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

# Version 2
groups_to_size = ->(reducer, group) { group.split.map(&:chars).reduce(reducer).size }
unionizer = groups_to_size.curry(2).call :|
intersecter = groups_to_size.curry(2).call :&

part1_v2 = ->(data) { data.then(&prepare).map(&unionizer).sum }
part2_v2 = ->(data) { data.then(&prepare).map(&intersecter).sum }
#######

ResultOutput.(
  info: 'V2 - Input data - union',
  data: INPUT_DATA.yield_self(&part1_v2),
  method: :==,
  expected: 7027
)

ResultOutput.(
  info: 'V2 - Input data - intersect',
  data: INPUT_DATA.yield_self(&part2_v2),
  method: :==,
  expected: 3579
)
