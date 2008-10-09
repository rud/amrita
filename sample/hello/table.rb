require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<table border="1">
  <tr><th>name</th><th>author</th></tr>
  <tr id=table1>
    <td id="name"><td id="author">
  </tr>
</table>
END

data = {
   :table1=>[ 
      { :name=>"Ruby", :author=>"matz" },
      { :name=>"perl", :author=>"Larry Wall" },
      { :name=>"python", :author=>"Guido van Rossum" },
   ] 
}
tmpl.prettyprint = true
tmpl.expand(STDOUT, data)

