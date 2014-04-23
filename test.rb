#!/usr/bin/ruby

puts `ls`

p ARGV

class ProcExample
  def pass_in_block(&action)
    @stored_proc = action
  end
  def use_proc(parameter)
    @stored_proc.call(parameter)
  end
end

eg =ProcExample.new
eg.use_proc(9)
