# This method escapes any string when inserting or updating a MySQl table in Ruby using single quotes
# You can use it everywhere when adding strings that could possibly have weird characters
def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "'''").gsub(/  /, ' ')
end

def html_data_scraping(client)
  c = <<~SQL
    CREATE TABLE IF NOT EXISTS covid_test_scraping_task_davi_mattos (
    id integer not null primary key auto_increment,
    week integer not null,
    total_spec_tested_including_age_unknown integer not null,
    total_percent_pos_including_age_unknown decimal(5, 2) not null,
    0_to_4_yrs_spec_tested integer not null,
    0_to_4_yrs_percent_pos decimal(5, 2) not null,
    5_to_17_yrs_spec_tested integer not null,
    5_to_17_yrs_percent_pos decimal(5, 2) not null,
    18_to_49_yrs_spec_tested integer not null,
    18_to_49_yrs_percent_pos decimal(5, 2) not null,
    50_to_64_yrs_spec_tested integer not null,
    50_to_64_yrs_percent_pos decimal(5, 2) not null,
    65_or_more_yrs_spec_tested integer not null,
    65_or_more_yrs_percent_pos decimal(5, 2) not null);
  SQL

  begin
    client.query(c)
    puts 'Table was created successfully!'
  rescue Mysql2::Error
    puts 'This table has already been created!'
  end

  # After creating the table, search the page and get the table element
  url = 'https://www.cdc.gov/coronavirus/2019-ncov/covid-data/covidview/01152021/specimens-tested.html'
  html = URI.open(url).read
  page = Nokogiri::HTML(html)
  filename = 'covid_test.csv'
  csv_options = {headers: :first_row, col_sep: ','}

  headers = %w(
      week
      total_spec_tested_including_age_unknown
      total_percent_pos_including_age_unknown
      0_to_4_yrs_spec_tested
      0_to_4_yrs_percent_pos
      5_to_17_yrs_spec_tested
      5_to_17_yrs_percent_pos 18_to_49_yrs_spec_tested
      18_to_49_yrs_percent_pos
      50_to_64_yrs_spec_tested
      50_to_64_yrs_percent_pos
      65_or_more_yrs_spec_tested
      65_or_more_yrs_percent_pos
  )
  # The csv file is created just for practicing
  # The data will be inserted in the same code snippet using normal INSERT queries
  CSV.open(filename, 'wb', **csv_options) do |csv|

    csv << headers

    # Search only for the rows that be in tbody
    page.search('table tbody tr').each do |row|
      # remove the comma from the integer values and parse to float only the values that has a dot
      cells = row.search('td').map { |e| e.text.gsub(/\,/, '').strip }
      cells = cells.map do |e|
        if e.include? '.'
          e = e.to_f
        else
          e = e.to_i
        end
      end
      f = <<~SQL
        INSERT INTO covid_test_scraping_task_davi_mattos (
        week,
        total_spec_tested_including_age_unknown,
        total_percent_pos_including_age_unknown,
        0_to_4_yrs_spec_tested,
        0_to_4_yrs_percent_pos,
        5_to_17_yrs_spec_tested,
        5_to_17_yrs_percent_pos, 
        18_to_49_yrs_spec_tested,
        18_to_49_yrs_percent_pos,
        50_to_64_yrs_spec_tested,
        50_to_64_yrs_percent_pos,
        65_or_more_yrs_spec_tested,
        65_or_more_yrs_percent_pos) 
        VALUES (
        #{cells[0]}, #{cells[1]}, #{cells[2]}, #{cells[3]}, #{cells[4]}, 
        #{cells[5]}, #{cells[6]}, #{cells[7]}, #{cells[8]}, #{cells[9]}, 
        #{cells[10]}, #{cells[11]}, #{cells[12]})
      SQL
      client.query(f)
      csv << cells
    end
  end
  # Load the file.csv in the database
  # I was getting an permission error due the user, so I decided to load the data using normal querys
  # f = <<~SQL
  #   LOAD DATA INFILE './covid_test.csv'
  #   INTO TABLE covid_test_scraping_task_davi_mattos
  #   FIELDS TERMINATED BY ','
  #   ENCLOSED BY ','
  #   LINES TERMINATED BY '\n'
  #   IGNORE 1 ROWS;
  # SQL
  # client.query(f)
end