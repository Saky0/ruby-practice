require 'mysql2'

client = Mysql2::Client.new(:host => "localhost",
                            :username => "root",
                            :password => "#DataBase1313",
                            :database => "local_tests")

client.query("LOAD DATA INFILE '/var/lib/mysql-files/people_csv.csv'
    INTO TABLE people_davi_mattos
    FIELDS TERMINATED BY ','
    ENCLOSED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;")
