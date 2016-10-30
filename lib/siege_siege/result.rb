module SiegeSiege
  class Result


    def initialize(command, urls, raw, raw_result)
      @command = command
      @raw = raw
      @raw_result = raw_result

      offset = 0
      @url_map = urls.each_with_index.inject({}) do |a, (url, index)|
        a.merge!((index + offset) => url).tap do
          # if the http method is POST, skip one step (why?)
          offset += 1 if url.post?
        end
      end
    end

    def total_result
      {
        command: @command
      }.merge!(
        @raw_result.split("\n").inject({}) { |a, line|
          if line.include?('unable to create log file')
            a
          elsif re = line.match(/(.+?):[^0-9]*([0-9\.]+) ?(.*)/)
            a.merge!(re[1].gsub(' ', '_').underscore.to_sym => {
              value: re[2].to_f,
              unit: re[3].to_s
            })
          else
            a
          end
        }
      )
    end

    def raw_log
      @stored_logs ||= begin
        @raw
          .gsub(/\e.+?m/, '')
          .gsub('[', '')
          .gsub(']', '')
          .split("\n")
          .map { |line| LineLog.new(*line.split(',')).take_in_detail(@url_map) rescue nil }
          .compact
      end
    end

    def average_log
      @stored_average_log ||= raw_log.group_by { |line| line.id }.map { |id, group|
        count = group.size
        average = (group.inject(0) { |a, log| a + log.secs } / count).round(3)
        head = group.first
        AverageLog.new(id, head.url, count, average, head.siege_url)
      }
    end
  end
end
