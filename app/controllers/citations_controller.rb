require 'citation'

class CitationsController < ApplicationController

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

     []

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

  def show
    if params[:citations]
      @citations = params[:citations].map {|c| Citation.find c.to_i}
    else
      @citations = [Citation.find((params[:id]||:first), :order=>[:id])]
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
end

