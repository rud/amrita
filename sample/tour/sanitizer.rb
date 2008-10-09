require "amrita/template"
include Amrita

tmpl = TemplateText.new %q[<p id=body>xxx</p>]


data = {
   :body=>"I want to insert new line.<br>But I can't"
}

tmpl.expand(STDOUT, data) # <p>I want to insert new line.&lt;br&gt;But I can't</p>
puts

data = {
    :body=>noescape { "I can insert new line <br>with escape { ... } <br>But it may be dangerous" }
}

tmpl.expand(STDOUT, data) # <p>I can insert new line <br>with escape { ... } <br>But it may be dangerous</p>
puts

data = {
    # The attacker expected amrita to print <p yyy=""></p>XSS attack<p>But amrita sanitize it!</p>
    :body=>a(:yyy=>%q["></p>XSS attack here<p]) { "But amrita sanitize it!" }
}
tmpl.expand(STDOUT, data) # <p yyy="&quot;&gt;&lt;/p&gt;XSS attack here&lt;p">But amrita sanitize it!</p>
puts

tmpl = TemplateText.new %q[<a id=body>href is treated in a special way</a>]

data = {
    :body=>a(:href=>%q[javascript:alert('hello')])
}
tmpl.expand(STDOUT, data) # <a href="">href is treated in a special way</a>
puts


