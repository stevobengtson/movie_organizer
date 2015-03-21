require 'titleize'
require 'streamio-ffmpeg'

module MovieOrganizer
  # This meta-class factory should accept the media filename, and from that
  # determine if it is likely to be:
  #
  # 1. a TV show
  # 2. a Movie
  # 3. a home video or other arbitrary video
  class Media
    attr_accessor :filename, :options, :logger, :settings

    def self.subtype(filename, options)
      instance = new(filename, options)
      return TvShow.new(filename, options) if instance.tv_show?
      Movie.new(filename, options)
    end

    def initialize(filename, options)
      @filename = filename
      @options = options
      @tv_show = nil
      @logger = Logger.instance
      @settings = Settings.new
    end

    def tv_show?
      return @tv_show unless @tv_show.nil?
      @tv_show = false
      @tv_show = true unless filename.match(/S\d+E\d+/i).nil?
      @tv_show = true unless filename.match(/\d+x\d+/i).nil?
      @tv_show
    end

    def resolution
      video = FFMPEG::Movie.new(filename)

      # first check the resolution field
      md = video.resolution.match(/^\d+x\d+$/)
      return md.string.split('x').last.to_i unless md.nil?

      # next check video stream
      md = video.video_stream.match(/\d\d\d+x\d\d\d+/)
      return md.string.split('x').last.to_i unless md.nil?

      fail "Cannot determine resolution\n#{video.inspect}"
    end

    def year
      md = basename.match(/\((\d\d\d\d)\)|(19\d\d)|(20\d\d)/)
      md ? md.captures.compact.first : nil
    end

    protected

    def basename
      File.basename(filename)
    end

    def ext
      File.extname(filename)
    end

    def verbose?
      options[:verbose]
    end

    def dry_run?
      options[:dry_run]
    end

    def sanitize(str)
      cleanstr = str.gsub(/-\s*-/, '')
      cleanstr = cleanstr.gsub(/\[?1080p\]?/, '').strip
      cleanstr = cleanstr.gsub(/\[?720p\]?/, '').strip
      cleanstr = cleanstr.gsub(/EXTENDED/, '').strip
      cleanstr = cleanstr.gsub(/YIFY/, '').strip
      cleanstr = cleanstr.gsub(/BluRay/i, '').strip
      cleanstr = cleanstr.gsub(/ECI/i, '').strip
      cleanstr = cleanstr.gsub(/HDTV/i, '').strip
      cleanstr = cleanstr.gsub(/x264/, '').strip
      cleanstr = cleanstr.gsub(/-lol/i, '').strip
      cleanstr = cleanstr.gsub(/[\.\s-]us[\.\s-]/i, '').strip
      cleanstr = cleanstr.gsub(/-\s*/, '').strip
      cleanstr = cleanstr.gsub(/\s\s+/, ' ').strip
      cleanstr.gsub(/[\.\+]/, ' ').strip
    end
  end
end
