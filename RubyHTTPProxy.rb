require 'socket'
require 'uri'
require 'net/http'
require 'json'

class RubyHTTPProxyServer

  def initialize(upstream_ip, upstream_port, local_port)
    @server = TCPServer.new('localhost', local_port.to_i)
    @request_injections = {} 
    @response_injections = {}
    @upstream_ip = upstream_ip
    @upstream_port = upstream_port
  end

  def run
    loop do
      socket       = @server.accept
      request_line = socket.gets

      unless request_line.nil?
        STDERR.puts request_line

        headers = {}
        socket.each_line do |line|
          break if line == "\r\n"
          header = line.split(": ")
          headers[header[0]] = header[1].strip!
        end

        body = ""
        i = 0
        while i < headers["Content-Length"].to_i
          body = body + socket.getbyte.chr
          i = i + 1
        end

        request = request_line.split(" ")
        uri = URI("http://#{@upstream_ip}:#{@upstream_port}#{request[1].gsub(/([^:])\/\//, '\1/')}")

        puts uri.path

        if @request_injections.has_key?(uri.path)
          @request_injections[uri.path].call(request, headers, body)
        end

        case request[0]
        when "GET"
          req = Net::HTTP::Get.new(uri.request_uri, initheader = headers) 
        when "POST"
          req = Net::HTTP::Post.new(uri.request_uri, initheader = headers) 
          req.body = body
        when "PUT"
          req = Net::HTTP::Put.new(uri.request_uri, initheaders = headers) 
          req.body = body
        when "DELETE"
          req = Net::HTTP::Delete.new(uri.request_uri, initheaders = headers) 
        end

        http = Net::HTTP.new(uri.host, uri.port)
        resp = http.request(req)

        if @response_injections.has_key?(uri.path)
          @response_injections[uri.path].call(resp)
        end

        # Response to request!
        socket.print "HTTP/#{resp.http_version} #{resp.code} #{resp.message}\r\n"
        resp.header.each_header do |key,value|
          socket.print "#{key}: #{value}\r\n"
        end
        socket.print "\r\n"
        socket.print resp.body

        socket.close
      end
    end
  end

  def on_request(url, &block)
    @request_injections[url] = block
  end

  def on_response(url, &block)
    @response_injections[url] = block
  end
end

if __FILE__==$0
  arg_keys = ["upstream_ip", "upstream_port", "local_port"]
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

  proxy = RubyHTTPProxyServer.new(args["upstream_ip"], args["upstream_port"], args["local_port"])
  proxy.on_response("/v2.0/tokens") do |resp|
    value = JSON.parse(resp.body)    
    value['access']['serviceCatalog'].each do |service|
      service['endpoints'].each do |endpoint|
        adminURL = URI(endpoint['adminURL'])
        internalURL = URI(endpoint['internalURL'])
        publicURL = URI(endpoint['publicURL'])
        adminURL.host = "localhost"
        internalURL.host = "localhost"
        publicURL.host = "localhost"
        endpoint['adminURL'] = adminURL.to_s
        endpoint['internalURL'] = internalURL.to_s
        endpoint['publicURL'] = publicURL.to_s
      end
    end
    resp.body = value.to_json
  end
  proxy.run
end
