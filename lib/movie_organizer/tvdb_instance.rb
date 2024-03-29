# frozen_string_literal: true

require 'tvdbr'

# A cached TV show lookup instance
module MovieOrganizer
  class TvdbInstance
    attr_reader :title, :year, :match, :tvdb

    def initialize(title, year = nil)
      @tvdb = Tvdbr::Client.new(api_key)
      @title = title
      @year  = year
    end

    def tv_show?
      @match = tvdb.find_series_by_title(title)
      sleep(0.25)
      return self if @match
      false
    end

    private

    def api_key
      ENV.fetch('TVDB_KEY') do
        Settings.instance[:tv_shows][:tvdb_key]
      end
    end
  end
end
