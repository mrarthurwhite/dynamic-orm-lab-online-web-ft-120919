require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    #binding.pry
    puts sql
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    results = DB[:conn].execute(sql, name)
      #remove_extra_keys(results)
  end

  def self.find_by(parameter_hash)
    key=parameter_hash.keys[0]
    value=parameter_hash[key]
    sql = "SELECT * FROM #{self.table_name} WHERE #{key} = \"#{value}\""
    #puts sql
    results = DB[:conn].execute(sql) # array of hash returned
      #remove_extra_keys(results)
   #binding.pry
  end

=begin
  def self.remove_extra_keys(results)
    results.map! do |hash|
      hash.delete_if do |k, v|
        k == 0 || k == 1 || k == 2
      end
    end
  end
=end


end