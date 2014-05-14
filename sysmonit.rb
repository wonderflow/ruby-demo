#!/usr/bin/env ruby

require 'yaml'
require 'net/ssh'
require 'net/scp'

class Sysmonit
  attr_accessor :cpu_num
  attr_accessor :average_load
  attr_accessor :cpu_idle
  attr_accessor :disk_use
  attr_accessor :mem_use
  attr_accessor :job
  attr_accessor :host

  def initialize(job,host,user,password)
    @host = host
    @user = user
    @password = password
    @job = job
  end

  def exec(ssh,ins,key)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec(ins)
        ch.on_data do |ch,data|
          if data.inspect.include?"[sudo]"; channel.send_data("password\n")
          else ; data.strip ; end
        end
      end
    end
  end

  def remote()
    Net::SSH.start(@host,@user,:password=>@password) do |ssh|
      @cpu_num = ssh.exec!("grep -c 'processor' /proc/cpuinfo").strip.to_i
      @load_15 = ssh.exec!("uptime | awk '{print $12}'").strip.to_f
      @average_load = @load_15 / @cpu_num
      @cpu_idle = ssh.exec!("top -b -n 1 | grep Cpu | awk '{print $5}' | cut -f 1 -d '.'").to_i
      @disk_use = ssh.exec!("df -h | grep /dev/xvda1 | awk '{print $5}' | cut -f 1 -d '%'").to_i
      if @disk_use < 1
        @disk_use = ssh.exec!("df -h | grep /dev/hda1 | awk '{print $5}' | cut -f 1 -d '%'").to_i
      end
      @mem_use = 100 - (ssh.exec!("free  -m | grep Mem | awk '{print ($4+$6+$7)/$2}'").to_f*100).to_i
    end
  end

  def local
    @cpu_num = `grep -c 'processor' /proc/cpuinfo`.strip.to_i
    @load_15 = `uptime | awk '{print $12}'`.strip.to_f
    @average_load = @load_15 / @cpu_num
    @cpu_idle = `top -b -n 1 | grep Cpu | awk '{print $5}' | cut -f 1 -d '.'`.to_i
    @disk_use = `df -h | grep /dev/xvda1 | awk '{print $5}' | cut -f 1 -d '%'`.to_i
    if @disk_use < 1
      @disk_use = `df -h | grep /dev/hda1 | awk '{print $5}' | cut -f 1 -d '%'`.to_i
    end
    @mem_use = 100 - (`free  -m | grep Mem | awk '{print ($4+$6+$7)/$2}'`.to_f*100).to_i
  end


  def work()
    @loacl_ip = `ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`.strip
    if @loacl_ip == @host
      local
    else 
      remote
    end
  end
end

@thread = []
@result = []
@yml = YAML::load_file("./config.yml")
@yml.each do |key,value|
  value.each do |ip|
    @result << Sysmonit.new(key,ip,'root','password')
  end
end
@result.each do |x|
  @thread << Thread.new do 
    host = x.host
    begin
      x.work
    rescue
      puts host+"connection failed."
    end
  end
end


loop do
  file = File.open(File.join('monitlog',"log"+Time.now.strftime("%Y%m%d%H%M")+".log"),"w")
  @thread.each do |th|
    th.join
  end
  file.puts Time.now.strftime("%Y-%m-%d %H:%M:%S")
  file.puts "Mem\tHd\tCPU\tJob\tHost"
  @result.each do |x|
    file.puts x.mem_use.to_s+"%\t"+x.disk_use.to_s+"%\t"+(x.average_load*100).to_i.to_s+"%"+"\t"+x.job+"\t"+x.host
  end
  file.close
  sleep 600
end
