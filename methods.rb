# frozen_string_literal: true

def get_teacher(id, client)
  f = "SELECT first_name, middle_name, last_name, birth_date FROM teachers_davi_mattos WHERE id = #{id};"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Teacher with ID #{id} was not found."
  else
    puts "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} was born on #{(results[0]['birth_date']).strftime('%d %b %Y (%A)')}"
  end
end

def get_subject_teachers(subject_id, client)
  f = "SELECT su.name as subject_name, te.first_name, te.middle_name, te.last_name FROM subjects_davi_mattos su JOIN teachers_davi_mattos te ON te.subject_id = su.id WHERE su.id = #{subject_id};"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Subject with ID #{id} was not found."
  else
    puts "Subject: #{results[0]['subject_name']}"
    results.each do |row|
      puts "Teacher: #{row['first_name']} #{row['middle_name']} #{row['last_name']}"
    end
  end
end

def get_class_subjects(class_name, client)
  f = "SELECT cl.name as class_name, su.name as subject_name, te.first_name, te.middle_name, te.last_name  FROM teachers_classes_davi_mattos tecl
      JOIN teachers_davi_mattos te
		    ON tecl.teacher_id = te.id
	    JOIN subjects_davi_mattos su
		    ON te.subject_id = su.id
	    JOIN classes_davi_mattos cl
		    ON tecl.class_id = cl.id
	    WHERE cl.name LIKE '%#{class_name}%';"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Class with Name #{class_name} was not found."
  else
    puts "Class: #{results[0]['class_name']}"
    results.each do |row|
      middle_name_initial = row['middle_name'].nil? ? '' : row['middle_name'][0].concat('.')
      puts "Subject: #{row['subject_name']} - Teacher: #{row['first_name']} #{middle_name_initial} #{row['last_name']}"
    end
  end
end

def get_teachers_list_by_letter(letter, client)
  f = "SELECT te.first_name, te.middle_name, te.last_name, su.name as subject_name FROM teachers_davi_mattos te
        JOIN subjects_davi_mattos su
          ON te.subject_id = su.id
        WHERE te.first_name like '%#{letter}%' or te.last_name like '%#{letter}%';"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Subject with ID #{id} was not found."
  else
    puts "Subject: #{results[0]['subject_name']}"
    results.each do |row|
      middle_name_initial = row['middle_name'].nil? ? '' : row['middle_name'][0].concat('.')
      first_name_initial = row['first_name'][0].concat('.')
      puts "Teacher: #{first_name_initial} #{middle_name_initial} #{row['last_name']} - Subject: #{row['subject_name']}"
    end
  end
end

def add_md5_column(client)
  f = 'ALTER TABLE teachers_davi_mattos ADD md5 char(32) null;'
  client.query(f)
end

def set_md5(client)
  f = 'SELECT * FROM teachers_davi_mattos;'
  results = client.query(f).to_a
  if results.count.zero?
    puts 'No teacher was found!'
  else
    results.each do |row|
      md5 = Digest::MD5.new
      middle_name = row['middle_name'].nil? ? '' : row['middle_name']
      str = "#{row['first_name']}#{row['middle_name']}#{row['last_name']}#{row['birth_date']}#{row['subject_id']}#{row['current_age']}"
      md5 << str
      f = "UPDATE teachers_davi_mattos SET md5 = '#{md5.hexdigest}' WHERE id = #{row['id']}"
      client.query(f)
    end
  end
end

def get_class_info(id, client)
  f = "select
        cl.name,
        CONCAT(te.first_name, ' ', COALESCE(te.middle_name, ''), ' ', te.last_name) as teacher_name,
        CONCAT(te_r.first_name, ' ', COALESCE(te_r.middle_name, ''), ' ', te_r.last_name) as responsible_teacher_name
        from teachers_classes_davi_mattos tecl
          JOIN teachers_davi_mattos te
          ON te.id = tecl.teacher_id
        JOIN classes_davi_mattos cl
          ON cl.id = tecl.class_id
        JOIN teachers_davi_mattos te_r
          ON te_r.id = cl.responsible_teacher_id
        WHERE cl.id = #{id};"
  results = client.query(f).to_a
  if results.count.zero?
    puts "No class with id #{id} was found"
  else
    str = "Class Name: #{results[0]['name']} \nResponsible Teacher: #{results[0]['responsible_teacher_name']} \nInvolved teachers: \n"
    count = 0
    results.each do |row|
      count += 1
      str += "#{count} - #{row['teacher_name']}\n"
    end
    str
  end
end

def get_teachers_by_year(year, client)
  f = "SELECT
        CONCAT(te.first_name, ' ', COALESCE(te.middle_name, ''), ' ', te.last_name) as teacher_name
        FROM teachers_davi_mattos te
        WHERE year(te.birth_date) = #{year};"
  results = client.query(f)
  if results.count.zero?
    puts "No teacher born in #{year} was found!"
  else
    str = "Teachers born in #{year}:\n"
    count = 0
    results.each do |row|
      count += 1
      str += "#{count} - #{row['teacher_name']}\n"
    end
    str
  end
end

def random_date(date_begin, date_end)
  t1 = Time.parse(date_begin)
  t2 = Time.parse(date_end)
  rand(t1..t2).strftime('%Y-%m-%d')
end

def random_last_names(n, client)
  f = "SELECT * FROM last_names ORDER BY rand() limit #{n}"
  results = client.query(f).to_a
  if results.count.zero?
    puts 'No values was found!'
  else
    results.map { |el| el['last_name'] }.join(', ')
  end
end

def random_last_names_local_variable(n, client)
  f = "SELECT * FROM last_names ORDER BY rand() limit #{n}"
  @results ||= client.query(f).to_a
  res = @results.sample(n).map { |r| (r['last_name']).to_s }.join(', ')
  if @results.count.zero?
    puts 'No values was found!'
  else
    res.to_s
  end
end

def random_first_names(n, client)
  f = 'SELECT m.FirstName as male_name, f.names as female_name FROM male_names m JOIN female_names f;'
  @results ||= client.query(f).to_a
  res = @results.sample(n).map do |el|
    rand(1..2) == 1 ? (el['male_name']).to_s : (el['female_name']).to_s
  end.join(', ')

  if @results.count.zero?
    puts 'No values was found!'
  else
    res.to_s
  end
end

# Methods from 2022-08-29
def create_table_random_people(client)
  f = "CREATE TABLE IF NOT EXISTS random_people_davi_mattos(
      id integer not null auto_increment primary key,
      first_name varchar (60) not null,
      last_name varchar (60) not null,
      birth_date date not null);"
  client.query(f)
  puts 'Table created sucefully!'
end

# I Thought two ways to do it:
# 1 - Get all registers of first names and last names then in ruby select a random field
# 2 - Get one register at a time and do a lot of queries to get the random fields (Using SQL)
#   until the specified number
def generate_random_people(n, client)
  # To begin with getting the random first_name (it can be male or female)
  f = 'SELECT m.FirstName as male_name, f.names as female_name FROM male_names m JOIN female_names f LIMIT 100;'
  first_name_results = client.query(f).to_a
  puts "Random people couldn't be generated!" if first_name_results.count.zero?

  f = 'SELECT last_name FROM last_names;'
  last_names_results = client.query(f).to_a
  puts "Random people couldn't be generated!" if last_names_results.count.zero?

  # insert one person at a time
  n.times do |p|
    first_name = first_name_results.sample(1)
                                   .map { |f| rand(1..2).to_i == 1 ? (f['male_name']).to_s : (f['female_name']).to_s }.join
    last_name = last_names_results.sample(1)
                                  .map { |l| (l['last_name']).to_s }.join
    # Generate the random birth_date
    t1 = Date.parse('1910-01-01')
    t2 = Date.parse('2022-12-31')
    birth_date = Date.parse(rand(t1..t2).strftime('%Y-%m-%d'))
    # Insert value by value
    f = "INSERT INTO random_people_davi_mattos (first_name, last_name, birth_date)
        VALUES ('#{first_name}', '#{last_name}', '#{birth_date}');"
    client.query(f)
    puts "#{p + 1} - Person: #{first_name.concat(' ', last_name)}"
  end
  puts "#{n} people have been created!"
end
