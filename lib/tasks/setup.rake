desc 'Ensure that code is not running in production environment'
task :not_production do
  raise 'do not run in production' if Rails.env.production?
end

desc 'Sets up the project by running migration and populating sample data'
task setup: [:environment, :not_production, 'db:drop', 'db:create', 'db:migrate'] do
  ["setup_sample_data"].each { |cmd| system "rake #{cmd}" }
end

def delete_all_records_from_all_tables
  ActiveRecord::Base.connection.schema_cache.clear!

  Dir.glob(Rails.root + 'app/models/*.rb').each { |file| require file }

  ActiveRecord::Base.descendants.each do |klass|
    klass.reset_column_information
    klass.delete_all
  end
end

desc 'Deletes all records and populates sample data'
task setup_sample_data: [:environment, :not_production] do
  delete_all_records_from_all_tables
  show = create_show
  create_episode show

  puts 'sample data was added successfully'
end

def create_show
  Show.create!({ slug:              "rubyindia",
                 title:             "RubyIndia Podcast",
                 short_description: "Indian Ruby Community Podcast",
                 description:       "RubyIndia Podcasts series meets people and speaks about their work, programming tools , work culture, technology stack and experiences. Its brought together by RubyIndia.About RubyIndia- It brings curated content from and for the Indian Ruby Community and friends.It aims to be a crowd sourced content aggregation of Articles, Blogs, Projects, Products, Highlights, News, and all things interesting, from the community.",
                 keywords:          "design, development",
                 itunes_url:        "https://itunes.apple.com/us/podcast/the-indian-ruby-podcast./id900116732",
                 email:             "vipul@bigbinary.com" })

end

def create_episode show
  Episode.create!({ title:         "Discussion with Bundler Core Team Members - Terence Lee and Smit Shah",
                    description:   "Interview with Bundler Core Team Members - Terence Lee and Smit Shah. Discussion about their early contributions to OSS, getting started with contributing to Bundler, future plans for Bundler and where it's headed.",
                    mp3_file_size: 50.6.megabytes,
                    number:        1,
                    show:          show,
                    duration:      69.07.minutes,
                    file_size:     50.6.megabytes,
                    published_on:  Time.current,
                    archive:       "https://ia800309.us.archive.org/14/items/rubyindia-podcast-12/rb-bundler.mp3" })

end
