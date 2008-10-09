require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<span id="time">
  <span id="year"></span>/<span id="month"></span>/<span id="day"></span>
</span>
END

t = Time.now
t.extend Amrita::ExpandByMember

data = { :time=>t }
tmpl.compact_space = true
tmpl.expand(STDOUT, data)

