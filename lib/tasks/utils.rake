namespace :db do
  desc 'Clears the citations table'
  task :clear_citations => :environment do
    Citation.destroy_all
  end
end

namespace :freecite do
  namespace :user do
    desc 'Add a user account to update citation data'
    task :create, [:username,:password] => :environment do |t, args|
      User.create_account(args.username, args.password)
    end
  end
end
  