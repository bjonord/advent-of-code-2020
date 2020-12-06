#!/usr/bin/env ruby

require 'set'
require_relative '../lib/result_output'

module SumOfEntries
  module_function

  SUM = 2020

  METHOD_CHOICE = {
    2 => :two_entries,
    3 => :three_entries
  }

  def call(num_entries)
    @num_entries = num_entries

    data = File.read('./day-1-inputs.txt').split("\n").map(&:to_i).to_set

    send(METHOD_CHOICE[num_entries], data)
  end

  def two_entries(data)
    large_and_small = data.group_by { |line| line.to_i > SUM / @num_entries }
    large_and_small[true].each do |large|
      small = large_and_small[false].detect { |small| small + large == 2020 }

      if small
        ResultOutput.(
          info: 'Input data - part 1',
          result: large * small,
          expected: 712_075
        )
        break
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
          ResultOutput.(
            info: 'Input data - part 2',
            result: first * second * third,
            expected: 145_245_270
          )
          exit
        end
      end
    end
  end
end


SumOfEntries.call(2)
SumOfEntries.call(3)
