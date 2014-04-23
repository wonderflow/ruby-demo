#!/usr/bin/ruby

require 'open-uri'
require 'net/http'

url_address = []


uri = URI("http://zjuam.zju.edu.cn/amserver/UI/Login?IDToken1=21321224&IDToken2=b3756919")
res = Net::HTTP.get_response(uri)
cookie = res['Set-Cookie']
cookie =  cookie.split('; ',2)[0]
cookie = "PHPSESSID=vp4lsmqgak2aa4563tjqetqsp4; amlbcookie=01; iPlanetDirectoryPro=AQIC5wM2LY4SfcwYjtYGV0XoCGtxAejyaNjRjjEsFka6%2FJg%3D%40AAJTSQACMDE%3D%23"
puts cookie

url_address << "http://ecard.zju.edu.cn/vpic.php?id=21321239"

imag = File.new("x.image","w")
url_address.each do |url|
  begin
    content = open(url,"Cookie" => cookie)
    p url
    cnt = 0
    while line = content.gets
      imag.puts line
      cnt += 1
    end
    p cnt
  rescue Exception
    p 'url gets failed.'
  end
end

=begin

pages = %w( www.rubycentral.org  slashdot.org  www.google.com )

threads = pages.map do |page_to_fetch|
  Thread.new(page_to_fetch) do |url|
    http = Net::HTTP.new(url+stuid, 80)
    print "Fetching: #{url}\n"
    resp = http.get('/')
    print "Got #{url}:  #{resp.message}\n"
  end
end
threads.each {|thr|  thr.join }

=end

