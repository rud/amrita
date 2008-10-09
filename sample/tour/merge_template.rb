require "amrita/template"
require "amrita/merge"
include Amrita

# This idea was suggested by Tom Sawyer


tmpfile = "/tmp/html1.html"

File::open(tmpfile, "w") do |f|
  f.write <<-END
  <html>
    <head>
      <title>Insertable</title>
    </head>
    <body>
      <span id="insert_me"><b>Hello World!</b></span>
    </body>
  </html>
  END
end

tmpl = TemplateText.new <<-END
  <html>
    <head>
      <title>Insertion MockUp</title>
    </head>
    <body id="data">
      This comes from a template fragment:
      <span id="#{tmpfile}#insert_me">This will be replaced.</span>
    </body>
  </html>
END

model_data = { :data => MergeTemplate.new}
tmpl.expand(STDOUT, model_data)

File::unlink tmpfile

__END__

the output of file2, when passed through Amrita, would then be:

  <html>
    <head>
      <title>Insertion MockUp</title>
    </head>
    <body>
      This comes from a template fragment:
      <span><b>Hello World!</b></span>
    </body>
  </html>
