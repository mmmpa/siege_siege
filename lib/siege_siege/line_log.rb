module SiegeSiege
  class LineLog < Struct.new(:protocol, :status, :secs, :bytes, :url, :id, :date, :siege_url)
    def initialize(*)
      super

      raise InvalidLine unless date

      self.secs = secs.to_f
      self.bytes = bytes.to_i
      self.id = id.to_i
      self.date = DateTime.parse(date)
    end

    def take_in_detail(url_map)
      self.siege_url = url_map[id]
      self
    end

    class InvalidLine < StandardError

    end
  end
end
