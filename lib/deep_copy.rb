module DeepCopy
  def deep_copy(data)
    Marshal.load(Marshal.dump(data))
  end
end
