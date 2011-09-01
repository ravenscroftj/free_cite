class AddEditionAndIdentifierToCitations < ActiveRecord::Migration
  def self.up
    add_column :citations, :edition, :text
    add_column :citations, :identifier, :text    
  end

  def self.down
    remove_column :citations, :edition
    remove_column :citations, :identifier
  end
end
