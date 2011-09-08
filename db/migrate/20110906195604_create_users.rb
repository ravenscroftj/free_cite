class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string
      t.column :password, :string
      t.timestamps
      t.index :username
    end

  end

  def self.down
    remove_column :users, :username    
    drop_table :users
  end
end