module ResultOutput
  module_function

  def call(info:, method: :==, expected:, result: 0)
    result = yield if block_given?

    if result.send(method, expected)
      puts "#{info} - \u2705: #{expected} #{method} #{result}"
    else
      puts "#{info} - \u274C: ! #{expected} #{method} #{result}"
      exit 1
    end
  end
end
