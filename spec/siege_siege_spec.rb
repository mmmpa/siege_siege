require 'spec_helper'

describe SiegeSiege do
  xit 'has a version number' do
    p @base
    _, stdout_pc, _ = Open3.popen3(%Q{siege -v -i -c 1 -t 10s #{@base} -A "a"})
    p stdout_pc.read
  end

  xit do
    SiegeSiege::Runner.new(
      time: 1,
      urls: [
        "#{@base}/",
        "#{@base}/not.html",
        "#{@base}/post.html POST a=1",
      ],
      internet: true
    ).run
  end

  xit do
    SiegeSiege::Runner.new(
      time: 1,
      url: "#{@base}/",
      internet: true
    ).run
  end

  it do
    pp SiegeSiege::Runner.new(
      time: 1,
      urls: [
        "#{@base}/",
        "#{@base}/not.html",
        "#{@base}/post.html POST a=1",
      ],
    ).run.average_log
  end
end
