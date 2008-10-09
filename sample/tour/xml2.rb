require "amrita/template"
require "rexml/document"
include Amrita

doc = REXML::Document.new <<END
<booklist>
  <book isbn="0596002149">
     <title>Ruby In A Nutshell</title>
     <author>Yukihiro Matsumoto</author>
     <author>David L. Reynolds</author>
  </book>
  <book isbn="0201710897">
     <title>Programming Ruby</title>
     <author>David Thomas</author>
     <author>Andrew Hunt</author>
  </book>
  <book isbn="0672320835">
     <title>The Ruby Way</title>
     <author>Hal Fulton</author>
  </book>
</booklist>
END

table = doc.elements.to_a("booklist/book").collect do |book|
  { 
    :title=>book.elements['title'],
    :authors=>book.elements.to_a('author').collect do |a|
      { :name=>a }
    end,
    #:isbn=>book.attributes['isbn']
    :isbn=>e(:a, :href=>"http://www.amazon.com/exec/obidos/ASIN/#{book.attributes['isbn']}") {
      book.attributes['isbn']
    }
  }
end

data = { :table1=>table }

html_tmpl = TemplateText.new <<END
<table border="1">
  <tr><th>title</th><th>author</th><th>ISBN</th></tr>
  <tr id=table1>
    <td id="title">
    <td><span id="authors"><span id="name"></span><br></span>
    <td id="isbn">
  </tr>
</table>
END

html_tmpl.prettyprint = true
#html_tmpl.set_hint(HtmlCompiler::AnyData.new)
html_tmpl.expand(STDOUT, data)

