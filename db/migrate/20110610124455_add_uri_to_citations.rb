class AddUriToCitations < ActiveRecord::Migration
  def self.up
    add_column :citations, :uri, :string
    add_index :citations, :uri
  end

  def self.down
    remove_column :citations, :uri
    remove_index :citation, :uri
  end
end
