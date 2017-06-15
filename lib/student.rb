require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
  end

  def self.create_table
    query = <<-SQL
    CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT
      grade TEXT
    );
    SQL
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(query)
  end

  def save
    if self.id
      self.update
    else
      query = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?);
      SQL
      DB[:conn].execute(query, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    self.new(name, grade).tap {|student| student.save}
  end

  def self.new_from_db(row)
    self.new(row[1], row[2]).tap {|student| student.id = row[0]}
  end

  def self.find_by_name(name)
    query = <<-SQL
    SELECT * FROM students WHERE name = ? LIMIT(1);
    SQL
    result_row = DB[:conn].execute(query, name)[0]
    self.new_from_db(result_row)
  end

  def update
    query = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(query, self.name, self.grade, self.id)
  end

end
