class Stage
  def call(_input)
    raise NotImplementedError, "#{self.class} must implement #call"
  end
end
