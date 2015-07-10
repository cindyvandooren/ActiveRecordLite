require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # debugger
    @foreign_key = options[:foreign_key].nil? ? "#{name}_id".to_sym : options[:foreign_key]
    @primary_key = options[:primary_key].nil? ? :id : options[:primary_key]
    @class_name = options[:class_name].nil? ? "#{name}".camelcase : options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key].nil? ? "#{self_class_name.downcase}_id".to_sym : options[:foreign_key]
    @primary_key = options[:primary_key].nil? ? :id : options[:primary_key]
    @class_name = options[:class_name].nil? ? "#{name}".camelcase.singularize : options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      fk = self.send(options.foreign_key)
      tmc = options.model_class
      result = tmc.where(options.primary_key => fk).first
    end
  end


  def has_many(name, options = {})
    # options = HasManyOptions.new(name, options)
    #
    # define_method(name) do
    #
    #
    # end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
