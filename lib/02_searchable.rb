require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_params = params.map { |key, _| "#{key}= ?" }
    where_line = where_params.join(" AND ")
    values = params.values

    db_rows = DBConnection.execute(<<-SQL, *values)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    db_rows.map { |row| self.new(row) }
  end
end

class SQLObject
  extend Searchable
end
