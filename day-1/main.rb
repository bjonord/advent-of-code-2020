#!/usr/bin/env ruby

require 'set'

module SumOfEntries
  module_function

  SUM = 2020

  METHOD_CHOICE = {
    2 => :two_entries,
    3 => :three_entries
  }

  def call(num_entries)

    @num_entries = num_entries

    data = File.read("./day-1-inputs.txt").split("\n").map(&:to_i).to_set

    self.send(METHOD_CHOICE[num_entries], data)
  end

  def two_entries(data)
    large_and_small = data.group_by { |line|  line.to_i > SUM/@num_entries }

    large_and_small[true].each do |large|
      small = large_and_small[false].detect { |small| small + large == 2020 }

      if small
        puts "--------------"
        puts "FOUND"
        puts "--------------"
        puts "entries: ", large, small
        puts "product: #{large * small}"
        puts "--------------"
        exit
      end
    end
  end

  def three_entries(data)
    data.each do |first|
      data.each do |second|
        third = data.detect do |third|
          first + second + third == 2020
        end

        if third
          puts "--------------"
          puts "FOUND"
          puts "--------------"
          puts "entries: ", first, second, third
          puts "product: #{first * second * third}"
          puts "--------------"
          exit
        end
      end
    end
  end
end


num_entries = ARGV.first.to_i
SumOfEntries.call(num_entries || 2)
