require "amrita/template"
include Amrita

tmpl = TemplateText.new <<END
<ul>
  <li id=list><font id=data></font>
</ul>
END

languages = %w(java Ruby perl python c++ c sml cobol fortran ada lisp)
i = 0 
data = {
  :list => languages.collect do |l|
    {
      :data => proc do |elem|
        if l == "Ruby" # Ruby is special language to me!
          # use Amrita::Element's methods to edit
          elem[:color] = "red" 
          elem[:size] = "big"
          elem.set_text("I love Ruby!")
          # e() is Amrita's method that generates Element
          e(:em) { elem } 
        else
          i = i + 1 # i is shared by all procs
          elem[:color] = i%2 == 0 ? "blue" : "black"
          elem.set_text(l)
          elem
        end
      end
    }
  end
}

tmpl.prettyprint = true
tmpl.expand(STDOUT, data)

