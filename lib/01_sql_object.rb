require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    array = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{table_name}"
      SQL

      array.first.map { |column_name| column_name.to_sym }
  end

  def self.finalize!
    columns.each do |column_name|
      # define_method(column_name) do
      #   get_instance_variable("@#{column_name}")
      # end
      define_method(column_name.to_sym) do
        attributes[column_name.to_sym]
      end
      #
      # define_method("@#{column_name} =".to_sym) do |new_value|
      #   set_instance_variable("@#{column_name}".to_sym, new_value)
      # end

      define_method("#{column_name}=".to_sym) do |new_value|
        attributes[column_name.to_sym] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        "#{table_name}".*
      FROM
        "#{table_name}"
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    objects = []

    results.each do |result|
      objects << self.new(result)
    end

    objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        "#{table_name}".*
      FROM
        "#{table_name}"
      WHERE
        "#{table_name}".id = ?
    SQL
    result == [] ? nil : self.new(result.first)
  end

  def initialize(params = {})
    params.each do |attribute, value|
      unless self.class.columns.include?(attribute.to_sym)
        raise "unknown attribute '#{attribute}'"
      end

      send("#{attribute}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attribute| send(attribute) }
  end

  def insert
    columns = self.class.columns
    col_names = columns.join(",")
    question_marks = (["?"] * columns.length).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    new_id = DBConnection.last_insert_row_id
    send(:id=, new_id)
  end

  def update
    attributes = self.class.columns.map { |attr| "#{attr}= ?" }
    setters = attributes.join(", ")

    #Don't need self.id, instance knows its own id.
    DBConnection.execute(<<-SQL, *attribute_values, {id: id})
      UPDATE
        #{self.class.table_name}
      SET
        #{setters}
      WHERE
        id = :id
      SQL
  end

  def save

  end
end
