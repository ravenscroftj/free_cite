class TaggedReferencesController < ApplicationController
  def index
    respond_to do |wants|
      wants.html {
        @references = TaggedReference.find(:all, :order=>["created_at DESC"])
        render
       }

       wants.text {
         references = TaggedReference.find_all_by_complete(true)
         lines = []
         references.each {|r| lines << r.tagged_string}
         render :text =>
           lines.join("\n"),
         :status => :ok
       }
    end    
  end

  def update
  end

  def destroy
  end

end
