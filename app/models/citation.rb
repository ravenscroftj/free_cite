# == Schema Information
# Schema version: 1
#
# Table name: citations
#
#  id          :integer       not null, primary key
#  raw_string  :text
#  original_string :text
#  uri         :string(255)
#  authors     :text          default(--- [])
#  title       :text
#  year        :integer
#  publisher   :text
#  location    :text
#  booktitle   :text
#  journal     :text
#  pages       :text
#  volume      :text
#  number      :text
#  contexts    :text          default(--- [])
#  tech        :text
#  institution :text
#  editor      :text
#  note        :text
#  marker_type :string(255)
#  marker      :string(255)
#

require 'rexml/document'
require 'crfparser'
require 'openurl'
require 'postprocessor'
require 'citation_to_context_object'
require 'utf8_parser'

class Citation < ActiveRecord::Base

  serialize :authors, Array
  serialize :contexts, Array
  
  def after_initialize
    self.authors  ||= [] 
    self.contexts ||= []
  end  

  def rating=(r)
    self[:rating] = r
  end

  def valid_citation?
    return true if authors.empty? && year
    return true if (location || booktitle) && year
    return true if title
    return false
  end

  def context_object
    @context_object ||= CitationToContextObject.to_context_obj(self)
  end

  def to_spans
    txt = to_xml.to_s
    txt.gsub!(/<([^>]*)\s+[^>]+\s*>/, '<\1>')
    txt.gsub!(/<\/[^>]*>/, "</span>")
    txt.gsub!(/<([^>^\/]*)>/, '<span class="\1">')
    txt.sub!(/<span class="raw_string">/, '<br><span class="raw_string">')
    txt.gsub!(/>/, '> ')
    txt
  end

  def to_xml
    doc = REXML::Document.new
    ci = doc.add_element("citation")
    aus = ci.add_element("authors")
    authors.each {|a|
      au = aus.add_element("author")
      au.text = a
    }
    ci.add_attribute("valid", valid_citation?.to_s)

    %w(title journal booktitle editor volume publisher institution location
       number pages year tech note ).each {|heading|

      if value = self.attributes[heading]
        el = ci.add_element(heading)
        el.text = value.to_s
      end
    }

    if !contexts.empty?
      ctxs = ci.add_element("contexts")
      contexts.each {|ctx|
        c = ctxs.add_element("context")
        c.text = ctx
      }
    end

    if marker
      el = ci.add_element("marker")
      el.text = marker.to_s
    end

    el = ci.add_element("raw_string")
    el.text = raw_string

    doc
  end

  def self.create_from_string(str)
    (uri,s) = str.split("||",2)
    str =  s if s
    orig_str = str.dup
    cp = CRFParser.new
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    # The strings we get might contain escaped UTF-8 directly from the original n-triples.
    begin
      utf8 = UTF8Parser.new(str)
      str = utf8.parse_string
    rescue;end
    valid_string = ic.iconv(str << ' ')[0..-2]
    valid_string = cp.normalize_citations(valid_string)
    hsh = cp.parse_string(valid_string)

    hsh.keys.reject {|k| Citation.column_names.include?(k)}.each {|k|
      hsh.delete k
    }
    cit = nil
    if s
      hsh["uri"] = uri 
      cit = self.find_or_create_by_uri(hsh["uri"])
      cit.update_attributes!(hsh)
    else
      hsh["original_string"] = orig_str
      hsh["md5_hash"] = Digest::MD5.hexdigest(orig_str).to_s
      cit = self.find_or_create_by_md5_hash(hsh["md5_hash"])
      # If we have a "marked up" string, assume the user has already gone through the effort of fixing 
      # a bad or incomplete parsing job
      unless TaggedReference.find_by_md5_hash(hsh["md5_hash"])
        cit.update_attributes!(hsh)
      end
    end
    cit
  end

end

