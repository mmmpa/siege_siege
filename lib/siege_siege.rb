require 'open3'
require 'tempfile'
require 'csv'
require 'pp'
require 'active_support'
require 'active_support/core_ext'

require 'siege_siege/version'
require 'siege_siege/average_log'
require 'siege_siege/configuration'
require 'siege_siege/line_log'
require 'siege_siege/result'
require 'siege_siege/runner'
require 'siege_siege/url'

module SiegeSiege
  def self.run(*args)
    Runner.new(*args).run
  end
end
