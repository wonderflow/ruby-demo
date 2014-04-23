#! /Users/wonderflow/.rvm/rubies/ruby-1.9.3-p545/bin/ruby

require 'yaml'
require 'net/ssh'
require 'net/scp'
#file = File.open('status.log','a')
#$stdout = file
#:wq

class Status

  def initialize()
    @x = []
    250.times do |i|
      @x << "10.10.18."+(i+1).to_s
    end
  end


  def exec(ssh,ins)
    ssh.open_channel do |channel|
      channel.request_pty do |ch,success|
        raise "I can't get pty request " unless success
        ch.exec(ins)
        ch.on_data do |ch,data|
          if data.inspect.include?"[sudo]"; channel.send_data("password\n")
          else ; puts data.strip ; end
        end
      end
    end
  end

  def connect(host,user,password)
    begin
      Timeout::timeout(1) do
        begin
          Net::SSH.start(host,user,:password=>password) do |ssh|
            puts host,user,password
            puts host+"succeed"
          end
        rescue StandardError => e
          return e.to_s
        end
      end
    rescue Timeout::Error
      #puts "time out!"
      puts '.'
    end
  end

  def get_through()
    @x.each do |str|
      connect(str,"alex","jiangqi")
    end
  end

  def work()
    get_through
  end
end

Status.new().work
