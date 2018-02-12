require 'socket'

tcp_server = TCPServer.new(9292)

counter = 0

while true
  client = tcp_server.accept

  while line = client.gets and !line.chomp.empty?
    output = "Hello, World! (#{counter})"
    headers = ['http/1.1 200 ok',
               "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
               'server: ruby',
               'content-type: text/html; charset=iso-8859-1',
               "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    client.puts headers
    client.puts output
  end

  counter += 1
end
