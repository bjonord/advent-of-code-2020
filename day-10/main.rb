#!/usr/bin/env ruby

require_relative '../lib/result_output'

DEMO = <<~DEMO.freeze
  16
  10
  15
  5
  1
  11
  7
  19
  6
  12
  4
DEMO

DEMO2 = <<~DEMO.freeze
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
DEMO

INPUT_DATA = File.read('./input.txt').freeze

class FindAdapterCombo
  attr_reader :adapters

  SortedAdapters = ->(adapters) { adapters.split("\n").map(&:to_i).then { |list| list << list.max + 3; list << 0 }.sort }
  FindJoltDifferences = ->(curr, coming) { coming - curr }

  def initialize(adapters)
    @adapters = SortedAdapters.(adapters)
  end

  def calculate
    adapters[0..-2].each_with_index do |adapter, index|
      FindJoltDifferences.(adapter, adapters[index + 1]).then do |diff|
        diff_stores[diff] += 1
      end
    end

    diff_stores[1] * diff_stores[3]
  end

  def diff_stores
    @diff_stores ||= {
      1 => 0,
      3 => 0,
    }
  end

  # Dynamic Programming - https://en.wikipedia.org/wiki/Dynamic_programming
  def number_of_goals(index = 0)
    # If it the last entry of adapters it is always within the threshold, so we return 1.
    return 1 if adapters.length - 1 == index
    # If we have already iterated over this index, then we skip it
    return ans_store[index] if ans_store.include? index

    sum = 0

    (index+1...adapters.length).each do |step_index|
      diff = FindJoltDifferences.(adapters[index], adapters[step_index])
      # Only keep going if the diff is within the threshold.
      if diff <= 3
        sum += number_of_goals(step_index)
      elsif diff > 3
        break
      end
    end

    ans_store[index] = sum
    sum
  end

  def ans_store
    @ans_store ||= {}
  end
end

ResultOutput.(
  info: 'Demo data',
  expected: 35
) { FindAdapterCombo.new(DEMO).calculate }

ResultOutput.(
  info: 'Demo data 2',
  expected: 220
) { FindAdapterCombo.new(DEMO2).calculate }

ResultOutput.(
  info: 'Input data - part 1',
  expected: 1848
) { FindAdapterCombo.new(INPUT_DATA).calculate }

ResultOutput.(
  info: 'Demo data',
  expected: 8
) { FindAdapterCombo.new(DEMO).number_of_goals }

ResultOutput.(
  info: 'Demo data 2',
  expected: 19208
) { FindAdapterCombo.new(DEMO2).number_of_goals }

ResultOutput.(
  info: 'Input data - part 2',
  expected: 8099130339328
) { FindAdapterCombo.new(INPUT_DATA).number_of_goals }
