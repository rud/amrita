require 'amrita/amx'

class AmritaDocumentTemplate < Amx::Template
  class Section
    include Amrita
    include Amrita::ExpandByMember
    attr_reader :title, :sections, :paragraphs
    
    def initialize(x)
      @title = convert(x.attributes['title'] || "")
      @sections = x.elements.to_a('section').collect do |sec|
        Section.new(sec)
      end

      @paragraphs = x.elements.find_all do |x|
        x.name != "section"
      end
    end
  end

  attr_reader :doc_root

  def befor_expand
    @doc_root = doc.elements['document']
    @refs = {}
    @doc_root.elements.to_a('head/links/ref').each do |ref|
      @refs[ref.attributes['id']] = ref.attributes['url']
    end
  end

  def header_title
    doc_root.elements['head/title']
  end

  def sections
    doc_root.elements.to_a('body/section').collect do |sec|
      Section.new(sec)
    end
  end

  def paragraphs
    doc_root.elements.find_all do |x|
      x.name != "section"
    end
  end

  def rexml2amrita(xml)
    case xml
    when REXML::Element
      case xml.name
      when "list"
        xml.name = "ul"
        super
      when "item"
        xml.name = "li"
        super
      when "code"
        xml.name = "tt"
        pre { super }
      when "link"
        id = xml.attributes['id']
        if id
          url = @refs[id]
          raise %Q[link "#{id}" not found] unless url
          e(:a, :href=>url) { convert(xml.get_text.to_s) }
        else
          url = xml.attributes['url']
          e(:a, :href=>url) { convert(xml.get_text.to_s) }
        end
      else
        super
      end
    else
      super
    end
  end
end
