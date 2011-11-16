require 'citation'

class CitationsController < ApplicationController
  
  before_filter :digest_authenticate, :except => [:index, :list, :show]

  def set_rating
    c = Citation.find(params[:id])
    c.rating = params[:rating]
    c.save!
    render :nothing => true
  end

  def index
    if params[:uri]
      @citations = Citation.find(:all, :conditions=>{:uri=>params[:uri]})
      respond_to do |wants|
        wants.html {
          if @citations.empty?
            render :text => "Couldn't parse any citations", :status => :bad_request
          else
            render :action => 'show', :citations => @citations
          end
         }
         wants.json {
           render :json => @citations.to_json
         }
         wants.xml {
           render :xml =>
             "<citations>\n" << citations2xml(@citations) << "</citations>\n",
           :status => :ok
         }
      end      
    else
      render :nothing => true
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list

    redirect_to :action => "show"
    
  end

  def create
    unless params[:citation]
      render :text => "Citation text is missing", :status => :bad_request
      return
    end

    if params["commit"]
      cstrs = params[:citation][:string].split(/\n+/).compact
    else
      cstrs = listify(params[:citation])
    end
    cstrs.reject! {|str| str.strip.empty?}

    okay = true
    @citations = cstrs.map {|cstr|
      citation = Citation.create_from_string(cstr)
      okay = false unless citation.id
      citation
    }

    if okay
      respond_to do |wants|
        wants.html {
          if @citations.empty?
            render :text => "Couldn't parse any citations", :status => :bad_request
          else
            render :action => 'show', :citations => @citations
          end
         }
         wants.json {
           render :json => @citations.to_json
         }
         wants.xml {
           render :xml =>
             "<citations>\n" << citations2xml(@citations) << "</citations>\n",
           :status => :ok
         }
      end
    else
      render :text => "Error creating citations: #{cstrs.join("\n")}",
             :status => :internal_server_error
    end
  end
  
  def update
    unless params[:id]
      render :text => "No id supplied!", :status => :bad_request
    end
    citation = Citation.find(params[:id])
    ignore_keys = [:id, :original_string, :tagged_string, :contexts]
    normalized_cite = {}
    params.each_pair do |key, value|
      next if ignore_keys.include?(key.to_sym)
      unless key.to_sym == :authors
        normalized_cite[key] = value
      else
        normalized_cite["author"] = value
      end
    end
      
    parser = CRFParser.new
    parser.normalize_fields(normalized_cite).each_pair do |key,value|
      citation[key] = value
    end
    citation.rating = "perfect"
    citation.save if citation.changed?
    tagged_ref = TaggedReference.find_or_create_by_md5_hash(citation.md5_hash)
    tagged_ref.tagged_string = tag_string(citation.attributes)
    tagged_ref.complete = tagged_string_complete?(tagged_ref.tagged_string, citation.attributes)
    tagged_ref.save if tagged_ref.changed?
    
    render :json => citation.to_json
  end

  def show
    if params[:citations]
      @citations = params[:citations].map {|c| Citation.find c.to_i}
    else
      @citations = [Citation.find((params[:id]||:first), :order=>:id)]
      respond_to do |wants|
        wants.html {
          if @citations.empty?
            render :text => "Couldn't parse any citations", :status => :bad_request
          else
            render :action => 'show', :citations => @citations
          end
         }
         wants.json {
           render :json => @citations.to_json
         }
         wants.xml {
           render :xml =>
             "<citations>\n" << citations2xml(@citations) << "</citations>\n",
           :status => :ok
         }
      end      
    end
  end

  private
  def listify(es)
    es ||= []
    es = [es] unless Array === es
    return es
  end
  def citations2xml(citations)
    citations.map{|c| "#{c.to_xml}\n#{c.context_object.xml}"}.join("\n")
  end
  def tag_string(hsh)
    str = hsh["original_string"].dup.chomp
    ignored_keys = ["id", "rating", "uri", "original_string", "raw_string", "marker", "marker_type", "md5_hash", "action", "controller", "author"]
    hsh.each_pair do |k,v|
      next if ignored_keys.include?(k) || v.nil? || (v.respond_to?(:empty?) && v.empty?)
      if k == "authors"
        start_string = v.first.split(/\s/).first
        end_string = v.last.split(/\s/).last
        unless str.sub!(/(#{Regexp.escape(start_string)}\s.*#{Regexp.escape(end_string)})/, ' <author> \1 </author> ')
          str.sub!(/(#{Regexp.escape(end_string)}\s.*#{Regexp.escape(start_string)})/, ' <author> \1 </author> ')
        end
      elsif k == "pages"
        if v =~ /\-\-/
          (s,e) = v.split("--")
          str.sub!(/(#{s}\s*\-{1,2}\s*#{e})/, ' <' + k + '> \1 </' + k + '> ')
        end        
      elsif v.to_s =~ /^\d*$/
        str.sub!(/((^|\D)#{v}(\D|$))/, ' <' + k + '> \1 </' + k + '> ')
      else
        str.sub!(/(#{Regexp.escape(v)})/, ' <' + k + '> \1 </' + k + '> ')
      end      
    end
    str
  end
  
  def tagged_string_complete?(str, cite)
    ignored_keys = ["id", "rating", "uri", "original_string", "raw_string", "marker", "marker_type", "md5_hash", "action", "controller", "author"]
    cite.each_key do |key|
      next if ignored_keys.include?(key) or (cite[key].nil? or (cite[key].respond_to?(:empty?) and cite[key].empty?))
      key = "author" if key == "authors"
      unless str.match(/\<#{key}\>/) && str.match(/\<\/#{key}\>/) 
        return false 
      end
    end
    true
  end
  def digest_authenticate
    success = authenticate_or_request_with_http_digest("Freecite") do |username|
      @user = User.find_by_username(username).try(:password)
    end

  end  
end

