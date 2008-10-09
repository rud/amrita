require "amrita/template"
include Amrita

tmpl = TemplateFile.new("template.html")
data = {
   :title => "hello world",
   :body => "Amrita is a html template libraly for Ruby"
}
tmpl.expand(STDOUT, data)

