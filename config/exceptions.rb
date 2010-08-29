class Exception
  def underscore
    self.class.name.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

class NotFound < RuntimeError
  def status; 404 end
end

class BadRequest < RuntimeError
  def status; 400 end
end