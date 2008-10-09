require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<table border="1">
  <tr><th>name</th><th>author</th><th>webpage</tr>
  <tr id=table1>
    <td id="name"></td>
    <td id="author"></td>
    <td><a id="title" href="@url"></a></td>
  </tr>
</table>
END

data = {
   :table1=>[ 
    { 
      :name=>"Ruby", 
      :author=>"matz" , 
      :url=>"http://www.ruby-lang.org/",
      :title=>"Ruby Home Page" 
    },
    { 
      :name=>"perl", 
      :author=>"Larry Wall" ,
      :url=>"http://www.perl.com/",
      :title=>"Perl.com"
    },
    { 
      :name=>"python", 
      :author=>"Guido van Rossum" ,
      :url=>"http://www.python.org/",
      :title=>"Python Language Website"
    },
   ] 
}
#tmpl.prettyprint = true
tmpl.use_compiler = true
tmpl.expand_attr = true
tmpl.set_hint_by_sample_data(data)
tmpl.expand(STDOUT, data)

