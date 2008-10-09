require "amrita/template"
include Amrita


tmpl_text = <<-END
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>xhtml sample</title>
</head>
<body>
  <h1 id=title>title</h1>
  <p id=body>body text</p>
  <hr />
</body>
</html>
   END

data = {
    :title => "SAMPLE1",
    :body => "members of this HASH will be inserted here and title"
}

tmpl = TemplateText.new tmpl_text
tmpl.prettyprint = true
# tmpl.xml = true # use REXML parser
tmpl.asxml = true
tmpl.expand(STDOUT, data)

