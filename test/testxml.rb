require 'runit/testcase'
require "amrita/xml"
require "amrita/format"
require "amrita/amx"

class TestXML < RUNIT::TestCase
  include Amrita
  include Amx

  def rexml_to_amrita(s)
    l = Listener.new
    REXML::Document.parse_stream(s, l)
    l.result.to_s
  end

  def test_listener
    a = '<a href="xxx">test</a>'
    assert_equal(a, rexml_to_amrita(a))
    a = '<h1><a href="xxx">test</a></h1>'
    assert_equal(a, rexml_to_amrita(a))
    a = '<h1> <a href="xxx">test</a> </h1>'
    assert_equal(a, rexml_to_amrita(a))
    a = '<h1> <a href="xxx">test</a><span class="yyy">testtest</span></h1>'
    assert_equal(a, rexml_to_amrita(a))
    a = '<ul><li>1</li><li>2</li><li>3</li></ul>'
    assert_equal(a, rexml_to_amrita(a))
    a = <<-END
<?xml version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>xhtml sample</title>
</head>
<body>
  <h1 id="title">title</h1>
  <p id="body">body text</p>
  <hr />
</body>
</html>
   END
    assert_equal('<?xml version="1.0"?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"> <head> <title>xhtml sample</title> </head> <body> <h1 id="title">title</h1> <p id="body">body text</p> <hr> </body> </html>',
       rexml_to_amrita(a))
  end

  def test_entity
    a = '<a href="&xxx">&amp;test</a>'
    # p rexml_to_amrita(a)
    assert_equal(a, rexml_to_amrita(a))
  end

  def test_amx1
    tmpfile="/tmp/amxtest#$$.amx"
    doc_text = <<END
  <?xml-stylesheet type="text/css" href="file:/home/ser/Work/documentation/documentation.css" ?>
  <?xml-stylesheet type="text/xsl" href="http://www.germane-software.com/svn/repos/documentation/paged.xsl" ?>
  <?amx href="#{tmpfile}" ?>
  <document>
    <head>
      <title>amx sample</title>
    </head>
    <body>
      <p>
        amx is a XML document.
        It contains model data as well-formed XML, HTML template 
        and a small Ruby code map both.
      </p>
      <p>
        This is a sample AMX document.
      </p>
    </body>             
  </document>
END
    doc = Amx::Document.new doc_text
    assert_equal(tmpfile, doc.template_href)

    template_text = <<END
<amx>

  <template> 
    <html>
      <body>
      xxxxx
        <h1 id="title">title will be inserted here</h1>
        <p id="body">body text will be inserted here</p>
        <hr />
      </body>
    </html>
  </template>

  <method id="get_model">
    <method_body>
      {
         :title => doc.elements['document/head/title'],
         :body => doc.elements.to_a('document/body/p')
      }
    </method_body>
  </method>
</amx>
END
      File.open(tmpfile, "w") { |f| f.write template_text }

      t = Amx::Template[tmpfile]
      result = ""
      t.prettyprint=false
      t.expand(result, doc)
      assert_equal(<<-END.strip, result.strip)
<html>
      <body>
      xxxxx
        <title>amx sample</title>
        <p>
        amx is a XML document.
        It contains model data as well-formed XML, HTML template 
        and a small Ruby code map both.
      </p><p>
        This is a sample AMX document.
      </p>
        <hr />
      </body>
    </html>
END
  ensure
    File::unlink tmpfile
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestXML.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestXML.new(method))
    end
  end
end
