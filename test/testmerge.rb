require 'runit/testcase'
require 'amrita/template'
require 'amrita/merge'

class TestMerge < RUNIT::TestCase
  include Amrita

  def test_merge1
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
    result = ""
    tmpl.expand(result, model_data)
    assert_equal(<<-END, result)
      <html>
        <head>
          <title>Insertion MockUp</title>
        </head>
        <body>
          This comes from a template fragment:
          <b>Hello World!</b>
        </body>
      </html>
      END
  ensure
    File::unlink tmpfile
  end

  def test_merge2
    tmpfile = "html1.html"

    File::open("/tmp/" + tmpfile, "w") do |f|
      f.write <<-END
      <html>
        <head>
          <title>Insertable</title>
        </head>
        <body>
         <span id="insert_me"><b id="xxx">Hello World!</b></span>
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
          <span id="yyy"></span>
        </body>
      </html>
    END

    m = MergeTemplate.new("/tmp") do
      # this model data will be applyed after merge.
      { :xxx=>"aaa",  :yyy=>"bbb" }
    end
    model_data = { :data => m }
    result = ""
    tmpl.expand(result, model_data)
    assert_equal(<<-END, result)
      <html>
        <head>
          <title>Insertion MockUp</title>
        </head>
        <body>
          This comes from a template fragment:
          <b>aaa</b>
          bbb
        </body>
      </html>
      END
  ensure
    File::unlink "/tmp/" + tmpfile
  end

  def test_mergewithcompile1
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
    result = ""
    tmpl.use_compiler = true
    tmpl.debug_compiler = true
    tmpl.expand(result, model_data)
    #puts tmpl.src
    assert_equal(<<-END, result)
      <html>
        <head>
          <title>Insertion MockUp</title>
        </head>
        <body>
          This comes from a template fragment:
          <b>Hello World!</b>
        </body>
      </html>
      END
  ensure
    File::unlink tmpfile
  end

  def test_mergewithcompile2
    tmpfile = "html1.html"

    File::open("/tmp/" + tmpfile, "w") do |f|
      f.write <<-END
      <html>
        <head>
          <title>Insertable</title>
        </head>
        <body>
         <span id="insert_me"><b id="xxx">Hello World!</b></span>
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
          <span id="yyy"></span>
        </body>
      </html>
    END

    m = MergeTemplate.new("/tmp") do
      # this model data will be applyed after merge.
      { :xxx=>"aaa",  :yyy=>"bbb" }
    end
    model_data = { :data => m }
    result = ""
    tmpl.use_compiler = true
    tmpl.expand(result, model_data)
    assert_equal(<<-END, result)
      <html>
        <head>
          <title>Insertion MockUp</title>
        </head>
        <body>
          This comes from a template fragment:
          <b>aaa</b>
          bbb
        </body>
      </html>
      END
  ensure
    File::unlink "/tmp/" + tmpfile
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestMerge.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestMerge.new(method))
    end
  end
end

