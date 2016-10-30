$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'siege_siege'
require 'webrick'

RSpec.configure do |config|
  config.before(:all) do
    @port = ENV['PORT'] || 3001
    @host = ENV['HOST'] || '127.0.0.1'
    @base = "http://#{@host}:#{@port}"
    Thread.start do
      WEBrick::HTTPServer.new(
        DocumentRoot: File.expand_path('./fixtures/', __dir__),
        BindAddress: @host,
        Port: @port,
        AccessLog: [],
        Logger: WEBrick::Log::new("/dev/null", 7)
      ).tap do |server|
        Signal.trap(:INT) { server.shutdown }

        server.mount_proc('/redirect') do |req, res|
          res.set_redirect(WEBrick::HTTPStatus::Found, '/redirected.html')
        end

        server.start
      end
    end
  end

  config.after(:all) do

  end
end