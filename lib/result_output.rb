module ResultOutput
  module_function

  def call(info:, result:, method: :==, expected:)
    if result.send(method, expected)
      puts "#{info} - \u2705: #{expected} #{method} #{result}"
    else
      puts "#{info} - \u274C: ! #{expected} #{method} #{result}"
      exit 1
    end
  end
end
