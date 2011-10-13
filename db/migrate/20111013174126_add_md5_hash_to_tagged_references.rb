class AddMd5HashToTaggedReferences < ActiveRecord::Migration
  def self.up
    add_column :tagged_references, :md5_hash, :string, :length=>255
    add_index :tagged_references, :md5_hash
  end

  def self.down
    remove_column :tagged_references, :md5_hash
    remove_index :tagged_references, md5_hash
  end
end
