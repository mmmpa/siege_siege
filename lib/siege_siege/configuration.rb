module SiegeSiege
  class Configuration
    OPTION_MAP = {
      verbose: 'v',
      concurrent: 'c',
      internet: 'i',
      time: 't',
      reps: 'r',
      log: 'l',
      mark: 'm',
      delay: 'd',
      header: 'H',
      user_agent: 'A',
      content_type: 'T',
      rc: 'R',
      file: 'f',
      url: ''
    }

    RC_MAP = {
      verbose: true,
      quiet: false,
      gmethod: 'HEAD',
      csv: false,
      timestamp: true,
      fullurl: true,
      display_id: true,
      limit: 255,
      show_logfile: true,
      logging: true,
      logfile: nil,
      protocol: 'HTTP/1.1',
      chunked: true,
      cache: false,
      timeout: 2000,
      expire_session: false,
      cookies: false,
      failures: 1024,
      benchmark: true,
      accept_encoding: 'gzip',
      url_escaping: true,
      spinner: false,
      login: nil,
      login_url: nil,
      ftp_login: nil,
      unique: true,
      ssl_cert: nil,
      ssl_key: nil,
      ssl_timeout: nil,
      ssl_ciphers: nil,
      proxy_host: nil,
      proxy_port: nil,
      proxy_login: nil,
      follow_location: true,
      zero_data_ok: true
    }

    def initialize(configuration)
      @configuration = configuration
    end

    def urls
      Array(@configuration[:urls]).map { |url|
        (URL === url ? url : URL.new(url))
      }
    end

    def rc
      RC_MAP.inject('') do |a, (key, default)|
        value = @configuration[key]
        inserting = value.nil? ? default : value
        if inserting.nil?
          a
        else
          a << "#{key.to_s.gsub('_', '-')} = #{inserting}\n"
        end
      end
    end

    def options
      OPTION_MAP.inject([]) { |a, (key, value)|
        inserting = @configuration[key]
        case
          when TrueClass === inserting
            a << "-#{value}"
          when FalseClass === inserting
            a
          when inserting && key == :time
            a << "-#{value} #{@configuration[key]}s"
          when inserting
            a << "-#{value} #{@configuration[key]}"
          else
            a
        end
      }.join(' ')
    end
  end
end
