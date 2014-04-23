#!/usr/bin/env ruby

require 'yaml'

yml = YAML::load_file('config.yml')

yml['components'].each do |key,value|
  puts key
  value.each do |ip|
    puts ip
  end
  puts "------"

end

puts yml['properties']['disksize']
