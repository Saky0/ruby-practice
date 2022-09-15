# This method escapes any string when inserting or updating a MySQl table in Ruby using single quotes
# You can use it everywhere when adding strings that could possibly have weird characters
def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "''").gsub(/  /, ' ')
end

def davi_hle_dev_cleaning(client)
  begin
    c = <<~SQL
      CREATE TABLE IF NOT EXISTS hle_dev_test_davi_mattos (
      id integer not null primary key auto_increment,
      candidate_office_name varchar(255) not null,
      clean_name varchar(255) null,
      sentence varchar(255) null
      );
    SQL
    client.query(c)
    puts 'Table was created successfully!'
    # I use this snippet to clean te table and set the first id = 1 in every time that I had restarted the script
    c = <<~SQL
      DELETE FROM hle_dev_test_davi_mattos;
    SQL
    client.query(c)
    c = <<~SQL
      ALTER TABLE hle_dev_test_davi_mattos auto_increment = 1;
    SQL
    client.query(c)
    #
  rescue Mysql2::Error
    puts 'This table has already been created!'
  end

  # INSERT all registers into hle_dev_test_davi_mattos from the hle_dev_test_candidates
  t = <<~SQL
    INSERT IGNORE INTO hle_dev_test_davi_mattos (candidate_office_name)#{' '}
    (SELECT DISTINCT candidate_office_name FROM hle_dev_test_candidates);
  SQL
  client.query(t)

  cr = <<~SQL
    SELECT id, candidate_office_name FROM hle_dev_test_davi_mattos WHERE clean_name is null;
  SQL
  results = client.query(cr).to_a
  if results.count.zero?
    puts 'No names to clean'
  else
    puts "Cleaning #{results.count} names..."
    results.each do |r|
      id = r['id']
      res = r['candidate_office_name']
      puts "= #{id} - #{res}"
      # the gsubs are using regex as asked to reformat the names
      # The string was reversed to remove the latest repeated words and then reversed again to the original format
      res = res.gsub(/Twp/, 'Township').
          gsub(/Hwy|Highway highway|Hwy hwy/, 'Highway').
          gsub(/Elem|EL/, 'Elementary School ').
          gsub(/H S|HS|Dist H S/, 'High School').
          gsub(/Schls|Schools/, 'School').
          gsub(/K-12|Public|School K-12/, 'Public School').
          gsub(/\b(\w*)(\w+)(\w*)\b(?=.*?\b\2\b)/, '')
      # Downcase everything that is not able to any pattern, thereafter the other cases will do downcase too
      res = res.match(/[\/\,]/) ? res : res.downcase
      # This Regex will do the sentece County Clerk/Recorder/DeKalb County becomes ‘DeKalb County clerk and recorder’
      res = res.gsub(/^(?<s1>[\w\']+(?!\/))? (?<s2>.+(?=\/)).+(?<s3>(?<=\/).+.*)/) do |match|
        # Deal with the cases that the string has doble '//'
        init = Regexp.last_match(:s3).strip
        second = Regexp.last_match(:s1).nil? ? '' : Regexp.last_match(:s1).strip
        optional_end = Regexp.last_match(:s2).gsub(/\/\//, '/').split('/')
        # Add the " and " if there's more than one value
        optional_end = optional_end.map(&:itself).join(' and ').downcase

        # If the name is all capitalized, keep and make no changes
        init = init.match(/^[A-Z ]+$/) ? init : init.split(' ').map(&:capitalize).join(' ')
        "#{init} #{second.downcase} #{optional_end}"
      end
      # Anything after a comma gets put in parentheses
      res = res.gsub(/^(.+(?=\,)).*((?<=\,).+)/) do |match|
        capitalize_parentheses = $2.split(' ').map(&:capitalize).join(' ')
        "#{$1.strip.downcase} (#{capitalize_parentheses})"
      end
      # Anything after a slash gets moved to the front of the name and remains capitalized
      res = res.gsub(/(.+(?=\/)).*((?<=\/)[\w ]+)/) { |match| "#{$2.split(' ').map(&:capitalize).join(' ')} #{$1.strip.downcase}" }
      # Due the last gsub, put everything inside the parentheses capitalized
      res = res.gsub(/\((.*)\)/) do |match|
        "(#{$1.split(' ').map(&:capitalize).join(' ')})"
      end
      # Fix the consecutive blanks
      res = res.gsub(/\s{2,}/, ' ')
      puts "#{res}"

      # UPDATE the register with the clean name in the field clean_name
      t = <<~SQL
        UPDATE hle_dev_test_davi_mattos SET clean_name = "#{escape(res)}", 
        sentence = "The candidate is running for the #{escape(res)} office" WHERE id = #{id}
      SQL
      client.query(t)

    end
  end
end
