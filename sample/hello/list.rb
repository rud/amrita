require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<ul>
  <li id=list1>
</ul>
END

data = {
   :list1=>[ 1, 2, 3 ]
}
tmpl.prettyprint = true
tmpl.expand(STDOUT, data)

