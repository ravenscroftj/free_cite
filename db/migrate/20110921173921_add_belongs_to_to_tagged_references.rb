class AddBelongsToToTaggedReferences < ActiveRecord::Migration
  def self.up
    add_column :tagged_references, :citation_id, :integer
    add_index :tagged_references, :citation_id
  end

  def self.down
    remove_column :tagged_references, :citation_id
    remove_index :tagged_references, :citation_id
  end
end
