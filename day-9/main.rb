#!/usr/bin/env ruby

require_relative '../lib/result_output'

DEMO = <<~DEMO.freeze
  35
  20
  15
  25
  47
  40
  62
  55
  65
  95
  102
  117
  150
  182
  127
  219
  299
  277
  309
  576
DEMO

INPUT_DATA = File.read('./input.txt').freeze

class CrackTheCode
  attr_reader :preamble, :list, :found_number

  def initialize(preamble, list)
    @preamble = preamble
    @list = list.split("\n").map(&:to_i)
  end

  def get_cracking(yield_self: false)
    list[preamble..-1].each_with_index do |number, index|
      curr_index = index + preamble
      res = list[index, curr_index - 1].permutation(2).detect { |a, b| a + b == number }

      unless res
        @found_number = number
        return yield_self ? self : number
      end
    end
  end

  def find_weakness
    step_over_partial_lists do |new_list|
      sum = 0
      new_list.each_with_object([]) do |number, arr|
        sum += number
        arr << number
        if sum == found_number && arr.length >= 2
          return arr.sort.then { |arr| arr.min + arr.max }
        end
      end
    end
  end

  def step_over_partial_lists
    list
      .each_with_index
      .map { |_, index| list[index..-1] }
      .each do |new_list|
        yield new_list
    end
  end
end

ResultOutput.(
  info: 'Demo data',
  result: CrackTheCode.new(5, DEMO).get_cracking,
  expected: 127
)

ResultOutput.(
  info: 'Input data - part 1',
  result: CrackTheCode.new(25, INPUT_DATA).get_cracking,
  expected: 22477624
)

ResultOutput.(
  info: 'Demo data',
  result: CrackTheCode.new(5, DEMO).get_cracking(yield_self: true).then { |res| res.find_weakness },
  expected: 62
)

ResultOutput.(
  info: 'Input data - part 2',
  result: CrackTheCode.new(25, INPUT_DATA).get_cracking(yield_self: true).then { |res| res.find_weakness },
  expected: 2980044
)
