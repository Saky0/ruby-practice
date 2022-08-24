require 'mysql2'
require 'dotenv/load'
require_relative './methods.rb'
require 'digest'
$client = Mysql2::Client.new(host: "db09.blockshopper.com",
                             username: ENV['DB09_LGN'],
                             password: ENV['DB09_PWD'],
                             database: "applicant_tests")


# get_teacher(1, $client)

# 1) get_subject_teachers which takes subject ID and returns a string:
# get_subject_teachers(3, $client)

# 2) get_class_subjects which will get class name and return next string:
# get_class_subjects('100', $client)

# 3) get_teachers_list_by_letter which will get a letter and return a list of teachers with their subjects in the next format:
# get_teachers_list_by_letter('a', $client)

# 4) Add new column md5 (char32) and make the necessary actions to fill every field
# add_md5_column($client)
# set_md5($client)

# 5) Create method get_class_info, which will get class ID an return next informartion:
# puts get_class_info(1, $client)

# 6) Create method get_teachers_by_year which will get a year and return result in the next format:
# "Teachers born in <YEAR>: <teacher name 1>, <teacher name 2> etc."
puts get_teachers_by_year(1965, $client)