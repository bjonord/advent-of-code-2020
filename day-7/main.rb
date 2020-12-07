#!/usr/bin/env ruby

require_relative '../lib/result_output'

DEMO = <<~DEMO.freeze
  light red bags contain 1 bright white bag, 2 muted yellow bags.
  dark orange bags contain 3 bright white bags, 4 muted yellow bags.
  bright white bags contain 1 shiny gold bag.
  muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
  shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
  dark olive bags contain 3 faded blue bags, 4 dotted black bags.
  vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
  faded blue bags contain no other bags.
  dotted black bags contain no other bags.
DEMO

DEMO2 = <<~DEMO2.freeze
  shiny gold bags contain 2 dark red bags.
  dark red bags contain 2 dark orange bags.
  dark orange bags contain 2 dark yellow bags.
  dark yellow bags contain 2 dark green bags.
  dark green bags contain 2 dark blue bags.
  dark blue bags contain 2 dark violet bags.
  dark violet bags contain no other bags.
DEMO2

class BagNode
  attr_reader :container, :contents, :associations

  def self.parse(string)
    container, contents = string.split(' contain ')
    contents = contents.split(', ').map do |bag|
      if bag.match?(/no other bags/)
        []
      else
        _, qty, name = *bag.match(/(\d+)\s(.*)\sbags?/)

        [name, qty.to_i]
      end
    end

    new(container.delete_suffix(' bags'), contents)
  end

  def initialize(container, contents)
    @container = container
    @contents = contents
  end

  # https://en.wikipedia.org/wiki/Breadth-first_search
  def find(name, rules)
    return true if children.keys.include?(name)

    children.keys.each do |key|
      return true if rules[key]&.find(name, rules)
    end

    false
  end

  # https://en.wikipedia.org/wiki/Depth-first_search sort of
  def calculate(rules)
    children.sum do |(name, qty)|
      name ? (qty * rules[name].calculate(rules)) + qty : 0
    end
  end

  def children
    @children ||= contents.each_with_object({}) { |child, acc| acc[child.first] = child.last }
  end
end

# https://en.wikipedia.org/wiki/Graph_(abstract_data_type)
class Rules
  attr_reader :rules

  def initialize(input_data)
    @rules = input_data.split(".\n").each_with_object({}) do |data, acc|
      bag = BagNode.parse(data)
      acc[bag.container] = bag
    end
  end

  def count(name)
    rules.count { |_, bag| bag.find(name, rules) }
  end

  def calculate(name)
    rules[name].calculate(rules)
  end
end

ResultOutput.(
  info: 'Demo data',
  result: Rules.new(DEMO).count('shiny gold'),
  expected: 4
)

INPUT_DATA = File.read('./input.txt').freeze

ResultOutput.(
  info: 'Input data - part 1',
  result: Rules.new(INPUT_DATA).count('shiny gold'),
  expected: 326
)

ResultOutput.(
  info: 'Demo data 2',
  result: Rules.new(DEMO2).calculate('shiny gold'),
  expected: 126
)

ResultOutput.(
  info: 'Input data - part 2',
  result: Rules.new(INPUT_DATA).calculate('shiny gold'),
  expected: 5635
)
