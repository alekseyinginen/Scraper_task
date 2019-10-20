require 'curb'
require 'nokogiri'
require 'mechanize'
require 'csv'
require_relative 'Scraper'

file_path = 'scraper_data.csv'
website_url = 'https://www.petsonic.com/snacks-huesos-para-perros/'
scraper_data = Scraper.new(website_url)
scraper_data.get_category_items
scraper_data.write_into_csv(file_path)