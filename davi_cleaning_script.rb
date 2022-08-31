# This method escapes any string when inserting or updating a MySQl table in Ruby using single quotes
# You can use it everywhere when adding strings that could possibly have weird characters
def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "''")
end

def davi_montana_uniq_district_cleaning(client)
  begin
    c = <<~SQL
      CREATE TABLE montana_public_district_report_card__uniq_dist_davi_mattos (
      id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
      name VARCHAR(255) NULL,
      clean_name VARCHAR(255) NULL,
      address VARCHAR(255) NULL,
      city VARCHAR(255) NULL,
      state VARCHAR(255) NULL,
      zip CHAR(20) NULL,
      UNIQUE (name, address, city, state, zip)
      ) engine=InnoDB;
    SQL
    client.query(c)
  rescue Mysql2::Error
    puts 'The table has already been created'
  end
  # INSERT IGNORE here using the UNIQUE key we made in the CREATE TABLE will skip over any duplicates to satisfy the UNIQUE key 
  t = <<~SQL
  insert ignore into montana_public_district_report_card__uniq_dist_davi_mattos (name, address, city, state, zip) 
    select DISTINCT school_name, address, city, state, zip from montana_public_district_report_card
  SQL
  client.query(t)

  cr = "select id, name from montana_public_district_report_card__uniq_dist_davi_mattos where clean_name is null"
  results = client.query(cr).to_a

  if results.count == 0
    puts "No names to clean"
  else
    puts "Cleaning #{results.count} names..."
    results.each do |r|
      id = r['id']
      res = r['name']
      # gsubs using regex to do all the editing we need for the clean school district names, including removing duplicates in the last piece of regex
      res = res.gsub(/Elem|EL/, 'Elementary School').
      gsub(/H S|HS|Dist H S/, 'High School').
      gsub(/Schls|Schools/, 'School').
      gsub(/K-12|Public|School K-12/, 'Public School').
      gsub(/(\b\w+\b) \1/, '\1')
      res << ' District'
      upd = "UPDATE montana_public_district_report_card__uniq_dist_davi_mattos SET clean_name = '#{escape(res)}' WHERE ID = #{id}"
      client.query(upd)
    end
  end
end
