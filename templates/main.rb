#!/usr/bin/env ruby

Dir["../lib/*.rb"].each {|file| require file }
ReadInput.(0)

class Klass
  include DeepCopy

  attr_reader :data
  def initialize(data)
    @data = data
  end

  def run
  end
end

ResultOutput.(
  info: 'Demo',
  expected: 0
) { Klass.new(ReadInput.sample).run }

ResultOutput.(
  info: 'Part 1',
  expected: 0
) { Klass.new(ReadInput.input).run }
