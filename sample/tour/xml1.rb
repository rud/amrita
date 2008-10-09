require "amrita/template"
require "amrita/xml"       # need REXML
include Amrita

data = {
   :table1=>[ 
      { :name=>"Ruby In A Nutshell", :author=>"Yukihiro Matsumoto, David L. Reynolds", :isbn=>"0596002149" },
      { :name=>"Programming Ruby", :author=>"David Thomas, Andrew Hunt", :isbn=>"0201710897" },
      { :name=>"The Ruby Way", :author=>"Hal Fulton", :isbn=>"0672320835" },
   ] 
}

html_tmpl = TemplateText.new <<END
<table border="1">
  <tr><th>name</th><th>author</th><th>ISBN</th></tr>
  <tr id=table1>
    <td id="name"><td id="author"><td id="isbn">
  </tr>
</table>
END

html_tmpl.prettyprint = true
puts "------------HTML output ----------------------"
html_tmpl.expand(STDOUT, data)

# output same model data in XML data file format.
xml_tmpl = TemplateText.new <<END
<booklist>
  <book id="table1">
     <title id="name" />
     <author id="author" />
     <isbn id="isbn" />
  </book>
</booklist>
END
puts "------------XML output ----------------------"

xml_tmpl.xml = true
xml_tmpl.expand(STDOUT, data)

puts "\n------------XML output(pretty-printed) ----------------------"

def xml_tmpl.setup_taginfo
  info = TagInfo.new
  info[:booklist].pptype = 1
  info[:book].pptype = 1
  info[:title].pptype = 2
  info[:author].pptype = 2
  info[:isbn].pptype = 2
  info
end

xml_tmpl.prettyprint = true
xml_tmpl.expand(STDOUT, data)
