require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<table border="1">
  <tr><th>name</th><th>author</th><th>webpage</tr>
  <tr id=table1>
    <td id="name"></td>
    <td id="author"></td>
    <td><a id="webpage"></a></td>
  </tr>
</table>
END

data = {
   :table1=>[ 
    { 
      :name=>"Ruby", 
      :author=>"matz" , 
      :webpage=> a(:href=>"http://www.ruby-lang.org/") { "Ruby Home Page" },
    },
    { 
      :name=>"perl", 
      :author=>"Larry Wall" ,
      :webpage=> a(:href=>"http://www.perl.com/") { "Perl.com" },
    },
    { 
      :name=>"python", 
      :author=>"Guido van Rossum" ,
      :webpage=> a(:href=>"http://www.python.org/") { "Python Language Website" },
    },
   ] 
}
tmpl.prettyprint = true
#tmpl.use_compiler = true
tmpl.expand(STDOUT, data)

