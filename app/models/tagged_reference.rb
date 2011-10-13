class TaggedReference < ActiveRecord::Base
  def citation
    return nil unless md5_hash
    Citation.find_by_md5_hash(self.md5_hash)
  end
end
