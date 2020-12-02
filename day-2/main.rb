#!/usr/bin/env ruby

require 'ostruct'

class PasswSet
  attr_reader :password

  def initialize(data)
    @policy, @char, @password = data.split(' ')
  end

  def char
    @char.gsub(':', '')
  end

  def policy
    policy_array = @policy.split('-')
    OpenStruct.new(low: policy_array.first.to_i, high: policy_array.last.to_i)
  end

  def valid_first_policy?
    res = password.count(char)
    res <= policy.high && res >= policy.low
  end

  def valid_second_policy?
    or_check = char_at_position?(policy.high) || char_at_position?(policy.low)
    and_check = char_at_position?(policy.high) && char_at_position?(policy.low)
    or_check && !and_check
  end

  def char_at_position?(position)
    password[position.pred] == char
  end
end

module ValidPasswords
  module_function

  def call
    puts 'FIRST POLICY:'
    puts prepared_data.select(&:valid_first_policy?).length
    puts 'SECOND POLICY:'
    puts prepared_data.select(&:valid_second_policy?).length
  end

  def prepared_data
    @prepared_data ||= input.map { |pass| PasswSet.new(pass) unless pass.empty? }.compact
  end

  def input
    @input ||= File.readlines('./input.txt')
  end
end

ValidPasswords.call
