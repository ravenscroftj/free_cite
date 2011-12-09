class AddArticleNumberToCitationsTable < ActiveRecord::Migration
  def self.up
    add_column :citations, :article_number, :text
  end

  def self.down
    remove_column :citations, :article_number
  end
end
