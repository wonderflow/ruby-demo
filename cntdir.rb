#!/usr/bin/env ruby

@result= []


def list_dir(dir,deep)
  sum = 0 
  Dir.foreach(dir) do |file|
    next if file=="." || file==".."
    file = File.join(dir,file)
    if File.directory?(file)
      sum += list_dir(file,deep+1)
    else 
      #puts file
      begin
        sum += File.size?file
      rescue
      end
    end
  end
  if @result[deep] == nil
    @result[deep] = ""
  end
  if sum>1024*1024
    @result[deep] << dir +" "+sum.to_s+"\n"
  end
  return sum
end

list_dir("cf-release",0)

@result.each do |x|
  print x
end
