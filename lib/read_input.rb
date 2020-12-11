module ReadInput
  module_function

  def call(arg)
    ['input', 'sample'].each do |type|
      send(:instance_variable_set, "@#{type}".to_sym, File.read("./#{arg}.#{type}").split("\n").freeze)
    end
  end

  def method_missing(method, *_args, &_block)
    if [:input, :sample].include? method
      send(:instance_variable_get, "@#{method.to_s}".to_sym)
    end
  end
end
