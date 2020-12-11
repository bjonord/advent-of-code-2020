#!/usr/bin/env ruby

Dir["../lib/*.rb"].each {|file| require file }
ReadInput.(11)

# Conway's game of life....
class Seats
  include DeepCopy

  attr_reader :data, :grid, :tolerance, :sight, :row_length, :column_length

  def initialize(data, tolerance: 4, sight: false)
    @data = data
    @tolerance = tolerance
    @sight = sight
    generate_grid
    @row_length = @grid.length - 1
    @column_length = @grid[0].length - 1
  end

  def generate_grid
    @grid = data.each_with_object([]) do |row, grid|
      row = row.split('')
      grid << (0...row.length).each_with_object({}) do |index, coll|
        coll[index] = row[index]
      end
    end
  end

  def occupied_adj(row, column, grid)
    directions.inject(0) do |sum, (dr, dc)|
      arow = row + dr
      acol = column + dc

      verify = ->(arow, acol) { (0..row_length).include?(arow) && (0..column_length).include?(acol) }

      if sight
        while verify.(arow, acol) && grid[arow][acol] == '.' do
          arow += dr
          acol += dc
        end
      end

      if verify.(arow, acol) && grid[arow][acol] == '#'
        sum += 1
      end
      sum
    end
  end

  def directions
    @directions ||= [-1, 0, 1].product([-1, 0, 1]).reject { |x, y| x == 0 && y == 0 }
  end

  def row_range
    @row_range ||= (0..row_length)
  end

  def column_range
    @column_range ||= (0..column_length)
  end

  def run
    grid_copy = []

    until grid == grid_copy do
      grid_copy = deep_copy(grid)
      row_range.each do |row|
        column_range.each do |column|
          occ_count = occupied_adj(row, column, grid_copy)

          grid[row][column] = '#' if grid[row][column] == 'L' && occ_count == 0
          grid[row][column] = 'L' if grid[row][column] == '#' && occ_count >= tolerance
        end
      end
    end

    grid.map { |row| row.select { |col, val| val == '#' }.length }.sum
  end
end

ResultOutput.(
  info: 'Demo',
  expected: 37
) { Seats.new(ReadInput.sample).run }

ResultOutput.(
  info: 'Part 1',
  expected: 2438
) { Seats.new(ReadInput.input).run }

ResultOutput.(
  info: 'Demo',
  expected: 26
) { Seats.new(ReadInput.sample, tolerance: 5, sight: true).run }

ResultOutput.(
  info: 'Part 2',
  expected: 2174
) { Seats.new(ReadInput.input, tolerance: 5, sight: true).run }
