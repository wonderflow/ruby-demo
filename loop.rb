while line = gets
  next if line =~ /^\s*#/  # skip comments
  break if line =~ /^END/   # stop at end
  # substitute stuff in backticks and try again
  redo if line.gsub!(/`(.*?)`/) { eval($1);p "x" }
  # process line ...
end

