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
          display_id: true,
          quiet: false,
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
      Result.new(@command, @urls, stdout.read, stderr.read)
    end
  end
end