require 'webrick'

@port = ENV['PORT'] || 3001
@host = ENV['HOST'] || '127.0.0.1'
@base = "http://#{@host}:#{@port}"

WEBrick::HTTPServer.new(
  DocumentRoot: File.expand_path('./spec/fixtures/', __dir__),
  BindAddress: @host,
  Port: @port,
  AccessLog: [],
  Logger: WEBrick::Log::new("/dev/null", 7)
).tap do |server|
  Signal.trap(:INT) { server.shutdown }
  server.start
end
