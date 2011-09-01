require 'crfparser.rb'

namespace :crfparser do
  desc 'train a CRF model for the citation parser'
  task :train_model => :environment do
    CRFParser.new.train
  end
  
  desc 'load tagged references file data into database'
  task :load_tagged_references, [:file] => :environment do |t,args|
    file = open(args.file)
    while line = file.gets
      TaggedReference.create(:tagged_string=>line.chomp.strip)
    end
  end
end

