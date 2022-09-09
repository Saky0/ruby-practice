# This method escapes any string when inserting or updating a MySQl table in Ruby using single quotes
# You can use it everywhere when adding strings that could possibly have weird characters
def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "'''")
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
      # the gsubs are using regex as asked to reformat the names
      # The string was reversed to remove the latest repeated words and then reversed again to the original format
      res = res.gsub(/Twp/, 'Township').
          gsub(/Hwy|Highway highway|Hwy hwy/, 'Highway').
          reverse.gsub(/\b(\w+)\b(?=.*?\b\1\b)/, '').reverse
      # Downcase everything unless the first word, so throughout the code capitalize only the specify words
      res = res.downcase.gsub(/^\b\w/, &:capitalize)
      # This Regex will do the sentece County Clerk/Recorder/DeKalb County becomes ‘DeKalb County clerk and recorder’
      res = res.gsub(/^(?<s1>\w+(?!\/)) (?<s2>.+(?=\/)).+(?<s3>(?<=\/).+.*)/) do |match|
        # Deal with the cases that the string has doble '//'
        init = Regexp.last_match(:s3).strip
        second = Regexp.last_match(:s1).strip
        optional_end = Regexp.last_match(:s2).gsub(/\/\//, '/').split('/')
        # Add the " and " if there's more than one value
        optional_end = optional_end.map(&:itself).join(' and ').downcase
        "#{init.split(' ').map(&:capitalize).join(' ')} #{second.split(' ').map(&:capitalize).join(' ')} #{optional_end}"
      end
      # Anything after a slash gets moved to the front of the name and remains capitalized
      res = res.gsub(/(.+(?=\/)).*((?<=\/)[\w ]+)/) { |match| "#{$2.strip} #{$1.strip.downcase}" }
      # Anything after a comma gets put in parentheses
      # res = res.gsub(/^(.+(?=\,)).*((?<=\,).+)/) { |match| "#{$1.strip.downcase} (#{$2.strip})"}
      res = res.gsub(/^(.+(?=\,)).*((?<=\,).+)/) do |match|
        capitalize_parentheses = $2.split(' ').map(&:capitalize).join(' ')
        "#{$1.strip.downcase} (#{capitalize_parentheses})"
      end
      # Capitalize only the first letter of the first word
      res = res.gsub(/^\b\w/, &:capitalize)

      # UPDATE the register with the clean name in the field clean_name
      t = <<~SQL
        UPDATE hle_dev_test_davi_mattos SET clean_name = "#{escape(res)}", 
        sentence = "The candidate is running for the #{escape(res)} office" WHERE id = #{id}
      SQL
      client.query(t)

    end
  end
end
