def get_teacher(id, client)
  f = "SELECT first_name, middle_name, last_name, birth_date FROM teachers_davi_mattos WHERE id = #{id};"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Teacher with ID #{id} was not found."
  else
    puts "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} was born on #{(results[0]['birth_date']).strftime("%d %b %Y (%A)")}"
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
  f = "ALTER TABLE teachers_davi_mattos ADD md5 char(32) null;"
  client.query(f)
end
def set_md5(client)
  f = "SELECT * FROM teachers_davi_mattos;"
  results = client.query(f).to_a
  if results.count.zero?
    puts "No teacher was found!"
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
      count +=1
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