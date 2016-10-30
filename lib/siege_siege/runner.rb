module SiegeSiege
  class Runner
    attr_accessor :conf, :urls

    def initialize(raw_configuration = {})
      @rc_file = Tempfile.open
      @urls_file = Tempfile.open
      @command = nil

      Configuration.new(
        {
          concurrent: 1,
          time: 10,
          reps: 1
        }.merge!(raw_configuration).merge!(
          verbose: true,
          rc: @rc_file.path,
          csv: true,
          display_id: false,
          quiet: false,
          follow_location: false,
          timestamp: false,
          file: raw_configuration[:url] ? nil : @urls_file.path
        )
      ).tap do |conf|
        File.write(@rc_file, conf.rc)
        File.write(@urls_file, conf.urls.map(&:to_siege_url).join("\n"))
        @command = "siege #{conf.options}"
        @urls = conf.urls
      end
    end

    def run
      puts "\e[32m#{@command}\e[0m"
      _, stdout, stderr = Open3.popen3(@command)

      indicate

      out = stdout.read
      err = stderr.read

      indicate_end

      Result.new(@command, @urls, out, err)
    ensure
      indicate_end
    end


    private

    def indicate
      @indicator = Thread.start do
        chars = %w[| / - \\]
        i = 0
        loop do
          print "\e[31m#{chars[i % chars.length]}\e[0m"
          sleep 0.1
          i += 1
          print "\b"
        end
      end
    end

    def indicate_end
      return unless @indicator
      Thread.kill(@indicator)
      print "\b"
      @indicator = nil
    end
  end
end
