require 'mysql2'

$client = Mysql2::Client.new(:host => "localhost",
                            :username => "root",
                            :password => "#DataBase1313",
                            :database => "local_tests")

# getting the orinal firstname_field and a modified firsname_field on a select
def getModifiedAndOrinalName
  results = $client.query("SELECT firstname as original_firstname, insert(firstname, 1, 1, 'B') as changed_firstname FROM people_davi_mattos WHERE firstname LIKE 'A%';")
  results.each do |row|
    puts row
  end
end

# changing permanently every firstname_field that starts with 'A' to 'B'
def updateFirstnameFieldByCondition
  results = $client.query("UPDATE people_davi_mattos SET firstname=Insert(firstname, 1, 1, 'A') WHERE firstname LIKE 'B%';")
  puts results
end

# create a new table with a new name and fill its with the people_davi_mattos values
def createNewTableFilledByPeopleDaviMattos (tableName = String.new)
  $client.query("CREATE TABLE IF NOT EXISTS #{tableName} (
      id int not null auto_increment,
      firstname varchar(20) not null,
      lastname varchar(50) not null,
      email varchar(60) not null,
      email2 varchar(60) not null,
      profession varchar(30) not null,
      primary key (id));")

  puts "New table created sucefully!"

  fillAnExistentTable(tableName, 'people_davi_mattos')
  puts "Filled table!"
end

# Fill a table using the data of another table
def fillAnExistentTable (leftTable = 'people_davi_mattos', rightTable = 'people_davi_mattos')
  $client.query("INSERT INTO #{leftTable}
      (id, firstname, lastname, email, email2, profession) (SELECT * FROM #{rightTable});")
end

# Insert a new column in some table (people_davi_mattos by default)
def insertNewColumnInTable (newColumn, table = 'people_davi_mattos')
  $client.query("ALTER TABLE #{table} ADD #{newColumn} varchar(40);")

  puts "Column #{newColumn} added sucefully"
end

# Insert a register in some table (people_davi_mattos by default)
def insertNewPeopleRegister (table = 'people_davi_mattos', id, firstname, lastname, email, secondEmail, profession)

  $client.query("INSERT INTO #{table} (id, firstname, lastname, email, email2, profession)
      VALUES (#{id}, '#{firstname}', '#{lastname}', '#{email}', '#{secondEmail}', '#{profession}');")

  puts "New register entered sucefully!"
end

loop do
  puts "\nChoose one option below:"
  puts '1 - Select all firstname values and change the first letter of a word that start with "A" to "B"'
  puts '2 - Update all firstname values and change the first letter of a word that start with "A" to "B"'
  puts '3 - Create a new table and fills its with the data of people_davi_mattos'
  puts '4 - Insert a new column on a table (people_davi_mattos by default, data type default = varchar(40)")'
  puts '5 - Insert a new register on a table (people_davi_mattos by default)'
  puts '0 - Close'
  print "Option: "
  option = gets.chomp.to_i

  case option
  when 1
    getModifiedAndOrinalName
    puts "\n"
  when 2
    updateFirstnameFieldByCondition
    puts 'Fields changed sucefully!'
  when 3
    print "Type the table name: "
    tableName = gets.chomp

    createNewTableFilledByPeopleDaviMattos(tableName)
  when 4
    print "Type the column name: "
    columnName = gets.chomp.strip

    insertNewColumnInTable(columnName)
  when 5
    print "Type the table name to insert the register: "
    table = gets.chomp.strip

    print "Type the id: "
    id = gets.chomp.to_i

    print "Type the first name: "
    firstname = gets.chomp.strip

    print "Type the last name: "
    lastname = gets.chomp.strip

    print "Type the email: "
    email = gets.chomp.strip

    print "Type the second email: "
    secondEmail = gets.chomp.strip

    print "Type the profession: "
    profession = gets.chomp.strip

    insertNewPeopleRegister(table, id, firstname, lastname, email, secondEmail, profession)
  when 0
    puts "\nExit..."
    break
  else
    puts "==== Invalid Option! ===="
  end

end



