class Client

  def initialize
    @tcp_server = TCPServer.new(9292)
  end

  def process
    while true
      @tcp_server.gets
      request
    end
  end

  def request
    'GET / HTTP/1.1
     Host: localhost:9292
     Connection: keep-alive
     Cache-Control: no cache
     User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit
                 /537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36
     Postman-Token: 0501bb48-d1e5-2538-765f-5fd213c384af
     Accept: */*
     DNT: 1
     Accept-Encoding: gzip, deflate, br
     Accept-Language: en-US,en;q=0.9'
  end
end
