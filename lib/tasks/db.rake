namespace :app do
  namespace :nouns do
    task :load => :environment do
      json = File.read("#{Rails.root}/lib/nounlist.json")
      nouns = JSON.parse(json)
      nouns.each do |name|
        Noun.create(name: name)
      end
    end
  end
end