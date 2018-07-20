require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    # update a record if called on an object that is already persisted
    if self.id
      self.update
    else
      # insert a new row into the database
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      # assign the id attribute
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE name = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.name)
  end

  def self.new_from_db(array)
    # convert database data into a Ruby object 
    new_student = self.new 
    new_student.id = array[0]
    new_student.name = array[1]
    new_student.length array[2]
    new_student
  end

  def self.find_by_name(name)
    # query the database table for a record that has a name of the name passed in as an argument
    # use the #new_from_db method to instantiate a Student object with the database row that the SQL query returns
  end

  def self.create(name:, grade:)
    student = Student.new(name, grade)
    student.save
    student
  end

end
