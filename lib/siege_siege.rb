require 'siege_siege/version'
require 'open3'
require 'tempfile'
require 'csv'
require 'pp'
require 'active_support'
require 'active_support/core_ext'


module SiegeSiege
  class Runner
    attr_accessor :conf, :urls

    def initialize(raw_configuration = {})
      @conf = Tempfile.open
      @urls = Tempfile.open
      @command = nil

      Configuration.new(
        {
          concurrent: 1,
          time: 10,
          reps: 1
        }.merge!(raw_configuration).merge!(
          verbose: true,
          rc: @conf.path,
          csv: true,
          display_id: true,
          quiet: false,
          file: raw_configuration[:url] ? nil : @urls.path
        )
      ).tap do |conf|
        File.write(@conf, conf.rc)
        File.write(@urls, conf.urls)
        @command = "siege #{conf.options}"
      end
      puts @command
    end

    def run
      _, stdout, stderr = Open3.popen3(@command)
      Result.new(stdout.read, stderr.read)
    end
  end

  class URL < Struct.new(:url, :method, :parameter)
    def initialize(*)
      super

      raise RequireURL unless url

      self.method ||= :get
      self.parameter ||= {}
    end

    def to_siege_url
      if method && method.to_s.downcase == 'post'
        [url, 'POST', parameter.to_param]
      else
        url
      end
    end

    class RequireURL < StandardError

    end
  end

  class Result
    def initialize(raw, raw_result)
      @raw = raw
      puts @raw_result = raw_result
    end

    def raw_log
      @stored_logs ||= begin
        @raw
          .gsub(/\e.+?m/, '')
          .gsub('[', '')
          .gsub(']', '')
          .gsub(' ', '')
          .split("\n").map { |line| LineLog.new(*line.split(',')) rescue nil }
          .compact
      end
    end

    def average_log
      @stored_average_log ||= raw_log.group_by { |line| line.id }.map { |id, group|
        count = group.size
        average = (group.inject(0) { |a, log| a + log.secs } / count).round(3)
        head = group.first
        AverageLog.new(id, head.url, count, average)
      }
    end
  end

  class AverageLog < Struct.new(:id, :url, :count, :secs)

  end

  class LineLog < Struct.new(:week_day, :date, :protocol, :status, :secs, :bytes, :url, :id, :date2)
    def initialize(*)
      super

      raise InvalidLine unless date2

      self.secs = secs.to_f
      self.bytes = bytes.to_i
      self.id = id.to_i
    end

    class InvalidLine < StandardError

    end
  end

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
        (URL === url ? url : URL.new(url)).to_siege_url
      }.join("\n")
    end

    def rc
      RC_MAP.inject('') do |a, (key, value)|
        inserting = @configuration[key] || value
        if inserting
          a << "#{key.to_s.gsub('_', '-')} = #{inserting}\n"
        else
          a
        end
      end
    end

    def options
      OPTION_MAP.inject([]) { |a, (key, value)|
        inserting = @configuration[key]
        case
          when TrueClass === inserting, FalseClass === inserting
            a << "-#{value}"
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
