require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<html>
  <body>
    <div id="groups">
       <h1 id="title"></h1>
       <div id=no_data>
          <em>This group has no data.</em>
       </div>
       <div id=one_data>
           This group has only one data: "<span id=data></span>".
       </div>
       <div id=many_data>
           Here's the list of this group's data.
           <ul>
             <li id=list>
           </ul>
       </div>
     </div>
   </body>
</html>
END

data = [
  ["Group A", %w(only_one)],
  ["Group B", %w(one two three)],
  ["Group C", %w()]
]

model_data = data.collect do |name, d|
  hash = {:title => name }
  case d.size
  when 0
    hash[:no_data] = true
  when 1
    hash[:one_data] = { :data=>d[0] }
  else
    hash[:many_data] = { :list=>d }
  end
  hash
end

tmpl.prettyprint = true
tmpl.expand(STDOUT, { :groups=>model_data })

