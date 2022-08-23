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
  results = $client.query("SELECT id, firstname as original_firstname FROM people_davi_mattos;").to_a

  results.each do |row|
    changed_name = row['original_firstname'].gsub(/^a/i, 'B')
    next if changed_name == row['original_firstname']
    $client.query("UPDATE people_davi_mattos SET firstname = '#{changed_name}' WHERE id = #{row['id']};")
  end

end

# create a new table with a new name and fill its with the people_davi_mattos values
def createNewTableFilledByPeopleDaviMattos (tableName = String.new)
  $client.query("CREATE TABLE IF NOT EXISTS #{tableName} (
      id int not null auto_increment,
      firstname varchar(255) not null,
      lastname varchar(255) not null,
      email varchar(255) not null,
      email2 varchar(255) not null,
      profession varchar(50) not null,
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

# Insert the string ' edited' in all lastname's
def edited_lastnames (client)
  results = client.query("SELECT id, lastname FROM people_davi_mattos;").to_a
  results.each do |row|
    next if row['lastname'].include? ' edited'
    modified_lastname = (row['lastname']).concat(' edited')
    client.query("UPDATE people_davi_mattos SET lastname = '#{row['lastname']}' WHERE id = #{row['id']};")
  end
end

# Make all emails lowercase if the same isn't lowercase
def emails_lowercase(client)
  results = client.query("SELECT id, email, email2 FROM people_davi_mattos;")
  results.each do |row|
    next if row['email'].downcase == row['email'] && row['email2'].downcase == row['email2']
    client.query("UPDATE people_davi_mattos SET email = '#{row['email'].downcase}', email2 = '#{row['email2'].downcase}' WHERE id = #{row['id']};")
  end
end

# Apply .strip method in all profession fields if the same has any blank space at the beginning or at the end
def strip_profession(client)
  results = client.query("SELECT id, profession FROM people_davi_mattos;")
  results.each do |row|
    next if row['profession'].strip == row['profession']
    client.query("UPDATE people_davi_mattos SET profession = '#{row['profession'].strip}' WHERE id = #{row['id']}';")
  end
end

loop do
  puts "\nChoose one option below:"
  puts '1 - Select all firstname values and change the first letter of a word that start with "A" to "B"'
  puts '2 - Update all firstname values and change the first letter of a word that start with "A" to "B"'
  puts '3 - Create a new table and fills its with the data of people_davi_mattos'
  puts '4 - Insert a new column on a table (people_davi_mattos by default, data type default = varchar(40)")'
  puts '5 - Insert a new register on a table (people_davi_mattos by default)'
  puts '6 - Add the string " edited" in all lastname\'s'
  puts '7 - Make all emails lowercase'
  puts '8 - Apply .strip in all profession fields'
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
  when 6
    edited_lastnames($client)
  when 7
    emails_lowercase($client)
  when 8
    strip_profession($client)
  when 0
    puts "\nExit..."
    break
  else
    puts "==== Invalid Option! ===="
  end

end



