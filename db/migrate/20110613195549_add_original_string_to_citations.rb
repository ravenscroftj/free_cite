class AddOriginalStringToCitations < ActiveRecord::Migration
  def self.up
    add_column :citations, :original_string, :text
  end

  def self.down
    remove_column :citations, :original_string
  end
end
