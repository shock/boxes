namespace :app do
  namespace :nouns do
    task :load_from_json => :environment do
      json = File.read("#{Rails.root}/lib/nounlist.json")
      nouns = JSON.parse(json)
      added = existed = 0
      nouns.each do |name|
        begin
          Noun.create(name: name)
          added += 1
        rescue
          existed +=1
        end
      end
      puts "#{existed} nouns already existed"
      puts "#{added} nouns added"
    end

    task :load_from_things => :environment do
      nouns = Thing.all.map(&:name).map{|e| e.split(/[^\w]+/)}.flatten.compact
      nouns = nouns.map(&:squish).map(&:downcase).reject{|e| e =~ /^[^a-z]/ || e =~ /[^a-z]$/}
      added = existed = 0
      nouns.each do |name|
        begin
          Noun.create(name: name)
          added += 1
        rescue
          existed +=1
        end
      end
      puts "#{existed} nouns already existed"
      puts "#{added} nouns added"
    end
  end
end