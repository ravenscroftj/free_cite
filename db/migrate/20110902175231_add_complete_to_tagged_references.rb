class AddCompleteToTaggedReferences < ActiveRecord::Migration
  def self.up
    add_column :tagged_references, :complete, :boolean, :default=>true
    add_index :tagged_references, :complete    
  end

  def self.down
    remove_column :tagged_references, :complete
    remove_index :tagged_references, :complete    
  end
end
