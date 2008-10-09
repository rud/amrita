# This sample converts the document of rexml


require "amrita/template"
require "rexml/document"
include Amrita

module ParagraphConverter
  TagConv = {
    "code" => "tt",
    "list" => "ul",
    "item" => "li",
  }
  def convert_paragraph(para)
    case para
    when REXML::Text, String
      TextElement.new(para.to_s)
    when REXML::Element
      case para.name
      when "link"
        e(:a, :href=>para.attributes['href']) { para.get_text }
      when "example"
        pre {
          e(:tt) { convert_paragraph(para.to_a) }
        }
      else
        tag = TagConv[para.name]
        tag = para.name unless tag
        e(tag.intern) { convert_paragraph(para.to_a) }
      end
    when Enumerable
      para.collect do |p|
        convert_paragraph(p)
      end
    else
      raise "unknown type #{para.type}"
    end
  end

end

class Section
  include ExpandByMember
  include Amrita::HtmlCompiler
  include ParagraphConverter

  attr_reader :subsections

  @@sec = 0

  def initialize(rexml_element, sec_no)
    @e = rexml_element
    @sec_no = sec_no
    subsec_no = 0
    @subsections = @e.to_a.collect do |sub|
      subsec_no = subsec_no + 1
      SubSection.new(sub, @sec_no, subsec_no)
    end
    @title = "#{@sec_no}. #{@e.name}"
    @@sec += 1
    @label = "s#{@@sec}"
  end

  def sec_title
    e(:a, :name=>@label) { @title }
  end

  def sec_index_title
    e(:a, :href=>"##{@label}") { @title }
  end

  def subsec_index
    subsections.collect do |ss|
      ss.subsec_title
    end
  end

  def amrita_generate_hint
    MemberData[ 
      :sec_title=>ScalarData,
      :subsections=>ArrayData[
        MemberData[ 
          :subsec_title=>ScalarData,
          :paragraphs=>ArrayData[NoHint],
        ]
      ]
    ]
  end
end

class SubSection
  include ExpandByMember
  include Amrita::HtmlCompiler
  include ParagraphConverter

  def initialize(rexml_element, sec_no, subsec_no)
    @e = rexml_element
    @sec_no, @subsec_no = sec_no, subsec_no
  end

  def subsec_title
    t = if @e.name == "subsection" 
          @e.attributes['title'] 
        else 
          @e.name
        end
    "#{@sec_no}. #{@subsec_no} #{t}"
  end

  def paragraphs 
    @e.collect do |para|
      Node::to_node(convert_paragraph(para))
    end
  end
end

doc = REXML::Document.new REXML::File.new("rexml_doc.xml")
doc_header, *doc_body = *doc.elements.to_a('documentation/*')

h = doc_header.elements
header = { 
  :title=>h['title'],
}

i = 0
body = {
  :body_header => {
    :banner  => a(:src=> h['banner'].attributes['href']),
    :bh_title=> h['title'],
  },
  :sections => doc_body.collect do |sec|
    i = i + 1
    Section.new(sec, i)
  end
}
body[:index] = { :sec_index => body[:sections] }

data = { :header=>header, :body=>body }

html_tmpl = TemplateText.new <<END
<html>
  <head id="header">
     <title id="title">header title</title>
  </head>
  <body id="body">
    <div id="body_header" align="center">
      <img id="banner"><h1 id="bh_title">document title</h1>
    </div>

    <div id="index">
      <ul>
         <li id="sec_index">
            <span id="sec_index_title"></span>
            <ul>
               <li id="subsec_index"></li>
            </ul>
         </li>
      </ul>
    </div>

    <div id="sections">
      <h2 id="sec_title">section title</h2>
      <div id="subsections">
        <h3 id="subsec_title">sub section title</h3>
        <span id="paragraphs"></span>
      </div>
    </div>
  </body>
</html>
END

html_tmpl.prettyprint = true
#html_tmpl.set_hint_by_sample_data(data)
html_tmpl.set_hint(HtmlCompiler::AnyData.new)
html_tmpl.expand(STDOUT, data)
