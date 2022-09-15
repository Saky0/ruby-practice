# frozen_string_literal: true
require 'mysql2'
require 'dotenv/load'
require_relative './methods.rb'
require_relative './methods_2022_08_30.rb'
require_relative './davi_cleaning_script.rb'
require_relative './davi_hle_test_02.rb'
require_relative './davi_data_scraping_task_01.rb'
require 'digest'
require 'time'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'
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
# puts get_teachers_by_year(1965, $client)

# === #
# 1) Create method random_date which will get date_begin and date_end and return random date between them
# random_date('2020-01-01', '2021-01-01')

# 2) create method random_last_names which will get attribute n and return n random last names from the table last_names as array of strings
# t = Time.now
# array = []
# 10.times do
#   array.push(random_last_names(2, $client))
# end
# puts array
# puts Time.now - t

# 3) create method random_first_names which will get attribute n and return n random first names from the tables male_names and female_names as array of strings.
# t = Time.now
# array = []
# 10.times do
#   array << random_first_names(1, $client)
# end
# puts array
# puts Time.now - t

## Methods from 2022-08-29
# 1) create new table random_people_<your name> to store first_name, last_name and birth_date there
# create_table_random_people($client)

# 2) create a method which will generate required (in argument) number of random combinations of first name, 
#   last name and birth date (between 1910 and 2022) and save them in your new table
# 3) test the method and when it works fine generate 10k people and calculate processing time
# t = Time.now
# generate_random_people(10000, $client)
# puts Time.now - t

## Methods from 2022-08-30
# 1) create new table - montana_public_district_report_card__uniq_dist_<your_name> with 
#   columns id, name, clean_name, address, city, state, zip
# create_table_uniq_districts($client)

# 2) copy information about unique districts into this table (consider district as unique if it has unique combination of name, address, city, state and zip!)
# select_uniq_district($client)
# insert_uniq_district($client)
#
# 3.1) clean district names and save them in clean_name column
# puts select_uniq_davi_m($client)
# clean_districts($client)
# puts select_uniq_davi_m($client)

# 3.2) Add 'district' at the end
# add_district_end($client)
# puts select_uniq_davi_m($client)

# 3.3) Delete all duplicated words
# del_dupplicated_words($client)
# davi_montana_uniq_district_cleaning($client)

## Methods from the hle test 02
davi_hle_dev_cleaning($client)
#

## Methods from the Scrape task
# html_data_scraping($client)


