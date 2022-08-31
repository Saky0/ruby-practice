def create_table_uniq_districts(client)
  f = "
      CREATE TABLE IF NOT EXISTS montana_public_district_report_card__uniq_dist_davi_mattos (
      id integer not null primary key auto_increment,
      name varchar(255) not null,
      clean_name varchar(255) null,
      address varchar(255) not null,
      city varchar(60) not null,
      state varchar(60) not null,
      zip varchar(20) not null
      );"
  client.query(f)
  puts 'Table created sucefully!'
end

def select_uniq_district(client)
  f = 'SELECT school_name, address, city, state, zip
      FROM montana_public_district_report_card GROUP BY school_name HAVING count(*) = 1'
  begin
    results = client.query(f).to_a
    if results.count.zero?
      puts 'No uniq district was found!'
    else
      results
    end
  rescue Mysql2::Error
    puts 'There was an error to select the uniq districts!'
  end
end

def insert_uniq_district(client)
  uniq_district = select_uniq_district(client)
  if uniq_district.nil? || uniq_district.count.zero?
    puts 'it won\'t be possible insert the values...'
  else
    begin
      uniq_district.length.times do |i|
        f = "INSERT INTO montana_public_district_report_card__uniq_dist_davi_mattos (name, address, city, state, zip)
            VALUES ('#{uniq_district[i]['school_name']}', '#{uniq_district[i]['address']}',
            '#{uniq_district[i]['city']}', '#{uniq_district[i]['state']}', '#{uniq_district[i]['zip']}');"
        client.query(f)
      end
      puts 'All uniq values were inserted sucefully!'
    rescue Mysql2::Error
      puts 'There was an error to insert the values!'
    end
  end
end

# This method select the uniq_values from table_davi_mattos
def select_uniq_davi_m(client)
  f = 'SELECT * FROM montana_public_district_report_card__uniq_dist_davi_mattos;'
  begin
    results = client.query(f).to_a
    if results.count.zero?
      puts 'No register was found!'
    else
      results
    end
  rescue Mysql2::Error
    puts 'There was an error to select the registers!'
  end
end

def clean_districts(client)
  # 1 - Cleaning the abbreviations of names
  results = select_uniq_davi_m(client)
  return if results.nil? || results.count.zero?

  results.length.times do |i|
    cleaned_name =
      results[i]['name'].gsub(/Elem|H S|K-12 Schools|K-12/,
                              { 'Elem' => 'Elementary School', 'H S' => 'High School',
                                'K-12' => 'Public School', 'K-12 Schools' => 'Public School'
                              })
    f = "
        UPDATE montana_public_district_report_card__uniq_dist_davi_mattos SET clean_name = '#{cleaned_name}'
        WHERE id = #{results[i]['id']}"
    begin
      client.query(f)
    rescue Mysql2::Error
      puts "There was an error to update the district #{results[i]['name']}"
    end
  end
end

def add_district_end(client)
  results = select_uniq_davi_m(client)
  return if results.nil? || results.count.zero?

  results.length.times do |i|
    next if results[i]['clean_name'].include? 'district'

    clean_name = results[i]['clean_name'].concat(' district')
    f = "
      UPDATE montana_public_district_report_card__uniq_dist_davi_mattos SET clean_name = '#{clean_name}'
      WHERE id = #{results[i]['id']}"
    begin
      client.query(f)
    rescue Mysql2::Error
      puts "There was an error to update the district #{results[i]['name']}"
    end
  end
end

def del_dupplicated_words(client)
  results = select_uniq_davi_m(client)
  return if results.nil? || results.count.zero?

  results.length.times do |i|
    original_name = results[i]['clean_name'].split(' ')
    # Group the string by duplicated words and count
    # If the count is more than 1, The code will delete the repeated word at the last occurrence
    # and automatically update the name in the database
    downcase_name = original_name.map(&:downcase).group_by(&:itself).map do |k, v|
      { word: k, count: v.length }
    end
    downcase_name.length.times do |j|
      next unless downcase_name[j][:count] > 1
      reverse_name = original_name.reverse
      index = reverse_name.find_index(downcase_name[j][:word])
      reverse_name.delete_at(index)
      # Put the name in the correct order
      clean_name = reverse_name.reverse.join(' ')
      f = "
      UPDATE montana_public_district_report_card__uniq_dist_davi_mattos SET clean_name = '#{clean_name}'
      WHERE id = #{results[j]['id']}"
      begin
        client.query(f)
      rescue Mysql2::Error
        puts "There was an error to update the district #{results[j]['name']}"
      end
    end
  end
end