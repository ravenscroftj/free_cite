class CreateTaggedReferences < ActiveRecord::Migration
  def self.up
    create_table :tagged_references do |t|
      t.column :tagged_string,  :text
      t.timestamps
    end
  end

  def self.down
    drop_table :tagged_references
  end
end
