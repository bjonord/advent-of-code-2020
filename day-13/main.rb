#!/usr/bin/env ruby

Dir["../lib/*.rb"].each {|file| require file }
ReadInput.(13)

class Klass
  include DeepCopy

  attr_reader :time, :busses, :busses_p2
  def initialize(data)
    @time = data.first.to_i
    @busses = data.last.split(',').select { |bus| bus != 'x' }.map(&:to_i)
    @busses_p2 = data.last.split(',')
      .each_with_index
      .select { |bus, _| bus != 'x' }
  end

  def run
    next_check = ->(ntime) do
      busses.each do |bus|
        if ntime % bus == 0
          return ntime, bus
        end
      end
      next_check.(ntime + 1)
    end

    ntime, bus = next_check.call(time)
    (ntime - time) * bus
  end

  # Solution using Chineese remainder theorem.
  # Sieve - https://en.wikipedia.org/wiki/Chinese_remainder_theorem#Search_by_sieving
  # Borrowed from: https://elixirforum.com/t/advent-of-code-2020-day-13/36180/5
  def run_part2
    sieve = lambda do |(x1, n1), (a2, n2)|
      x = x1
      x2 = loop do
        break x if x % n2 == a2
        x += n1
      end
      [x2, n1 * n2]
    end

    mods_and_rems = busses_p2
      .map { |id, index| [id.to_i, index] }
      .map { |id, index| [(id - index) % id, id] }
      .sort_by(&:first)
      .reverse

    mods_and_rems.reduce(&sieve).sort.first
  end
end

ResultOutput.(
  info: 'Demo',
  expected: 295
) { Klass.new(ReadInput.sample).run }

ResultOutput.(
  info: 'Part 1',
  expected: 222
) { Klass.new(ReadInput.input).run }

ResultOutput.(
  info: 'Demo',
  expected: 1_068_781
) { Klass.new(ReadInput.sample).run_part2 }

ResultOutput.(
  info: 'Part 2',
  expected: 408_270_049_879_073
) { Klass.new(ReadInput.input).run_part2 }
