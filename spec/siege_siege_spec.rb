require 'spec_helper'

module SiegeSiege
  describe Runner do
    before :all do
      @result = SiegeSiege.run(
        time: 2,
        user_agent: false,
        urls: [
          "#{@base}/",
          "#{@base}/not.html",
          "#{@base}/post.html POST a=1",
        ],
      )
    end

    let(:result) { @result }
    let(:total_result) { result.total_result }
    let(:command) { total_result[:command] }

    it do
      expect(result).to be_a(SiegeSiege::Result)
    end

    it do
      expect(result.average_log.size).to eq(3)
    end

    it do
      expect(result.average_log.first.siege_url.http_method).to eq(:get)
    end

    it do
      expect(result.average_log.last.siege_url.http_method).to eq(:post)
    end

    it do
      expect(command).to include('2s')
    end

    it do
      expect(command).not_to include('-A')
    end

    it do
      SiegeSiege.run(
        time: 5,
        url: "#{@base}/"
      )
    end
  end

  describe URL do
    before :all do
      @string_url = SiegeSiege::URL.new('http://example.com')
      @post_string_url = SiegeSiege::URL.new('http://example.com POST a=1')

      @url = SiegeSiege::URL.new('http://example.com')
      @post_url = SiegeSiege::URL.new('http://example.com', :post, {a: 1})
      @post_url_string_parameter = SiegeSiege::URL.new('http://example.com', :post, 'a=1')
    end

    it do
      expect(@string_url.http_method).to eq(:get)
    end

    it do
      expect(@post_string_url.http_method).to eq(:post)
    end

    it do
      expect(@post_string_url.to_siege_url).to include('a=1')
    end

    it do
      expect(@post_string_url.to_siege_url).to include('POST')
    end

    it do
      expect(@post_url_string_parameter.to_siege_url).to include('a=1')
    end
  end
end
