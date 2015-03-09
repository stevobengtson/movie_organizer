require 'faker'
require 'titleize'

shared_context 'media_shared' do
  let(:tmpdir) { File.join(MovieOrganizer.root, 'tmp') }

  after(:each) do
    FileUtils.rm(Dir.glob("#{tmpdir}/*"))
  end

  def random_season_episode_string
    season = (1..12).to_a.sample.to_s.rjust(2, '0')
    episode = (1..33).to_a.sample.to_s.rjust(2, '0')
    "S#{season}E#{episode}"
  end

  # The.Walking.Dead.S05E02.720p.HDTV.x264-KILLERS
  def fake_movie_name(extension, tvshow = true)
    if tvshow
      filename = "#{Faker::App.name}.#{random_season_episode_string}.#{extension}"
    else
      filename = "#{Faker::Hacker.verb.titleize} #{Faker::App.name}.#{extension}"
    end
    File.join(tmpdir, filename)
  end

  def create_test_file(extension, options = {})
    tvshow = options.fetch(:tvshow, true)
    count = options.fetch(:count, 1)
    filename = options.fetch(:filename, false)
    files = []
    if filename
      files = [File.join(tmpdir, filename)]
      File.open(files.last, 'w') { |f| f.write("Fake Media File\n") }
    else
      count.times do
        files << fake_movie_name(extension, tvshow)
        File.open(files.last, 'w') { |f| f.write("Fake Media File\n") }
      end
    end
    files
  end
end
