#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__)

file = File.open(File.join('..','config','x.yml'),'r')
puts file.gets
puts __FILE__
