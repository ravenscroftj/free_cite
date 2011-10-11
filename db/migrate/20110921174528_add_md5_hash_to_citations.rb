class AddMd5HashToCitations < ActiveRecord::Migration
  def self.up
    add_column :citations, :md5_hash, :string, :length=>255
    add_index :citations, :md5_hash
  end

  def self.down
    remove_column :citations, :md5_hash
    remove_index :citations, md5_hash
  end
end
