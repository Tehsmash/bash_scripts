require 'ropenstack'
require 'uri'

class OpenStackPortForward
  def initialize(keystone_ip, keystone_port, username, password, tenant)
    command = "ssh%{portforwards} %{host} -N"
    partial = " -L %{port}:%{address}:%{port}"
    host = "localhost"

    identity = Ropenstack::Identity.new("http://#{keystone_ip}", keystone_port, nil, "identityv2")
    identity.authenticate(username, password)
    identity.scope_token(tenant)		

    endpoints = []
    portforwards = ""

    identity.services().each do |service|
      service['endpoints'].each do |endpoint|
        uri = URI(endpoint['internalURL'])
        ep = [uri.host, uri.port]
        unless endpoints.include? ep
          endpoints.push(ep)
          portforwards = portforwards + (partial % {port: ep[1], address:ep[0]})
        end
      end
    end

    Process.fork do
      exec("/bin/bash", "-c", command % {portforwards:portforwards, host:host})
    end

    Process.wait
  end
end

# Example
# ruby test.rb --keystone_ip <keystone_ip_address> --keystone_port <keystone_port> --username admin --password password --tenant tenant

if __FILE__==$0
  arg_keys = ["keystone_ip", "keystone_port", "username", "password", "tenant"]
  args = {}
  last_was_arg = nil
  while arg = ARGV.shift 
    if arg[0, 2] == "--"
      last_was_arg = arg[2,arg.length] 
    elsif last_was_arg and arg_keys.delete(last_was_arg)
      args[last_was_arg] = arg 
      last_was_arg = nil
    end
  end

  unless arg_keys.length == 0
    puts "Please include these arguments:"
    puts arg_keys 
    exit
  end

  OpenStackPortForward.new(args["keystone_ip"], args["keystone_port"], args["username"], args["password"], args["tenant"])
end
