class Exception
  def underscore
    self.class.name.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

class NotFound < Exception
  def status; 404 end
end

class BadRequest < Exception
  def status; 400 end
end

class ConnectionNotFound < NotFound
  def message; "No connection found using current algorithm and parameters" end
end

