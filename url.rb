require 'open-uri'
require 'net/http'

url_address = []
url_address << "http://10.10.101.106/resources"
url_address << "http://10.10.10.10/resources"
url_address << "http://10.10.101.106/scripts"

url_address.each do |url|
  begin
    content = open(url)
    p url
    cnt = 0
    while line = content.gets
      cnt += 1
    end
    p cnt
  rescue Exception
    p 'url gets failed.'
  end
end

pages = %w( www.rubycentral.org  slashdot.org  www.google.com )

threads = pages.map do |page_to_fetch|
  Thread.new(page_to_fetch) do |url|
    http = Net::HTTP.new(url, 80)
    print "Fetching: #{url}\n"
    resp = http.get('/')
    print "Got #{url}:  #{resp.message}\n"
  end
end
threads.each {|thr|  thr.join }

