class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}".to_sym)
      end

      define_method("#{name}=") do |new_value|
        instance_variable_set("@#{name}".to_sym, new_value)
      end
    end
  end
end
