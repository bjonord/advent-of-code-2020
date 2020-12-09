#!/usr/bin/env ruby

require_relative '../lib/result_output'

DEMO = <<~DEMO.freeze
  nop +0
  acc +1
  jmp +4
  acc +3
  jmp -3
  acc -99
  acc +1
  jmp -4
  acc +6
DEMO

INPUT_DATA = File.read('./input.txt').freeze

class RunCode
  attr_reader :accumulator

  def initialize(input_commands)
    @input_commands = input_commands
    @accumulator = 0
  end

  def input_commands
    @input_commands.split("\n").each_with_object([]) { |command, arr| arr << [command, 0] }
  end

  def run
    execute(input_commands[0], 0)
    accumulator
  end

  def run_and_find_fix
    input_commands.each_with_index do |(command, _), index|
      m = command.match(/(jmp|nop)\s.\d/)
      next if m.nil?

      xcommands = input_commands
      xcommands[index] = [command.gsub(m[1], new_command(m[1])), 0]

      reset_acc
      res = execute(xcommands[0], 0, xcommands)
      return res if res
    end
  end

  private

  def reset_acc
    @accumulator = 0
  end

  def new_command(command)
    command == 'nop' ? 'jmp' : 'nop'
  end

  def execute(command, index, xcommands = input_commands)
    return false if command.last >= 1

    old_index = index
    xcommands[index] << 1

    case command.first.split
      in ['nop', _]
        index += 1
      in ['acc', add]
        @accumulator += add.to_i
        index += 1
      in ['jmp', lines]
        index += lines.to_i
    end

    return accumulator if old_index >= xcommands.length - 1

    execute(xcommands[index], index, xcommands)
  end
end

ResultOutput.(
  info: 'Demo data',
  result: RunCode.new(DEMO).run,
  expected: 5
)

ResultOutput.(
  info: 'Input data - part 1',
  result: RunCode.new(INPUT_DATA).run,
  expected: 1675
)

ResultOutput.(
  info: 'Demo data 2',
  result: RunCode.new(DEMO).run_and_find_fix,
  expected: 8
)

ResultOutput.(
  info: 'Input data - part 2',
  result: RunCode.new(INPUT_DATA).run_and_find_fix,
  expected: 1532
)
