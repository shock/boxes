# Like Hashie::Mash but works like you want - ie. it doesn't dup value objects, it stores the originals
# Also works like HashWithIndifferentAccess
class HashObj < Hash

  def initialize(hash=nil)
    super()
    if hash
      deep_update(hash)
    end
  end

  def [](key)
    if self.has_key?(key.to_s)
      return super(key.to_s)
    elsif self.has_key?(key.to_sym)
      return super(key.to_sym)
    end
    return nil
  end

  def []=(key, value)
    super(key.to_sym, value)
  end

  def id
    return self[:id]
  end

  def client_attributes
    hash = {}
    self.each do |k,v|
      hash[k] = v
    end
    hash
  end

  def method_missing(method, *args)
    method = method.to_s
    if matches = method.match( /([\w-]*)=/ )
      key = matches[1].to_sym
      return self[key] = args[0]
    else
      return self[method]
    end
  end

private
  def deep_update(hash)
    hash.each do |k, v|
      v = self.class.new(v) if v.is_a?(Hash)
      if v.is_a?(Array)
        v.map! {|e| e.is_a?(Hash) ? self.class.new(e) : e }
      end
      self.send("#{k}=", v)
    end
  end
end

if __FILE__ == $0
  obj = HashObj.new(:id => -1)
  raise "failure" unless obj.id == -1
end