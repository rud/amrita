require 'runit/testcase'
require 'amrita/template.rb'

class TestTemplate < RUNIT::TestCase
  include Amrita
  include HtmlCompiler

  def test_template_text_direct1
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal('<p>aaa</p>', result)
  end

  def test_template_text_direct2
    html = '<ul><li id="list">list</li>'
    t = TemplateText.new(html)
    result = ""
    data = { :list => [1, 2, 3] }
    t.expand(result, data)
    assert_equal('<ul><li>1</li><li>2</li><li>3</li></ul>', result)
  end

  def test_template_compile1
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    t.use_compiler = true
    result = ""
    #t.set_hint(HashData[:a=>ScalarData])
    t.expand(result, { :a=>"aaa" })
    #puts t.src
    assert_equal('<p>aaa</p>', result)
  end

  def test_template_text_compile2
    html = '<ul><li id="list">list</li>'
    t = TemplateText.new(html)
    t.use_compiler = true
    result = ""
    data = { :list => [1, 2, 3] }
    t.set_hint(HashData[:list=>ArrayData[ScalarData]])
    t.expand(result, data)
    assert_equal('<ul><li>1</li><li>2</li><li>3</li></ul>', result)
  end

  def test_template_autocompile1
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    t.use_compiler = true
    result = ""
    data = { :a=>"aaa" }
    t.set_hint_by_sample_data(data)
    t.expand(result, data)
    #puts t.src
    assert_equal('<p>aaa</p>', result)
  end

  def test_template_text_autocompile2
    html = '<ul><li id="list">list</li>'
    t = TemplateText.new(html)
    t.use_compiler = true
    result = ""
    data = { :list => [1, 2, 3] }
    t.set_hint_by_sample_data(data)
    t.expand(result, data)
    assert_equal('<ul><li>1</li><li>2</li><li>3</li></ul>', result)
  end

  def test_template_text_autocompile3
    html = '<ul><li id="list">list</li>'
    t = TemplateText.new(html)
    t.use_compiler = true
    result = ""
    data = { :list => [1, 2, 3] }
    t.set_hint_by_sample_data(data)
    t.expand(result, data)
    assert_equal('<ul><li>1</li><li>2</li><li>3</li></ul>', result.gsub("\n",""))
  end


  def test_template_file1
    tempfile = "/tmp/amritatest#{$$}"
    File.open(tempfile, "w") { |f| f.print <<-END }
    <p id="a">sample_text</p>
    END

    t = TemplateFile.new(tempfile)  
    assert_equal(true, t.need_update?)
    result = ""
    t.expand(result, { :a=>"aaa" })
    sleep 1.1 # for test of need_update?
    assert_equal("    <p>aaa</p>\n", result)
    result = ""
    t.expand(result, { :a=>"111" })
    assert_equal(false, t.need_update?)
    assert_equal("    <p>111</p>\n", result)
    File.open(tempfile, "w") { |f| f.print <<-END }
    <p id="a">sample_text</p>xxx
    END
    result = ""
    assert_equal(true, t.need_update?)
    t.expand(result, { :a=>"aaa" })
    assert_equal("    <p>aaa</p>xxx\n", result)
    assert_equal(false, t.need_update?)
  ensure
    #File.open(tempfile) { |f| puts f.read }
    File::unlink(tempfile)
  end

  def test_template_file2
    tempfile = "/tmp/amritatest#{$$}"
    File.open(tempfile, "w") { |f| f.print <<-END }
    <p id="a">sample_text</p>
    END

    t = TemplateFile.new(tempfile)  
    t.xml = true
    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal("<p>aaa</p>", result)
  ensure
    File::unlink(tempfile)
  end

  def test_keep_id
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    t.keep_id = true

    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal('<p id="a">aaa</p>', result)

    result = ""
    t.set_hint(HashData[:a=>ScalarData])
    t.expand(result, { :a=>"aaa" })
    #puts t.src
    assert_equal('<p id="a">aaa</p>', result)
  end

  def test_escaped_id
    html = '<p id="a" __id="realid">sample_text</p>'
    t = TemplateText.new(html)
    t.escaped_id = :__id

    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal('<p id="realid">aaa</p>', result)

    result = ""
    t.set_hint(HashData[:a=>ScalarData])
    t.expand(result, { :a=>"aaa" })
    #puts t.src
    assert_equal('<p id="realid">aaa</p>', result)
  end

  def test_amrita_id
    html = '<p amrita_id="a" id="realid">sample_text</p>'
    t = TemplateText.new(html)
    t.amrita_id = :amrita_id

    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal('<p id="realid">aaa</p>', result)

    result = ""
    t.set_hint(HashData[:a=>ScalarData])
    t.expand(result, { :a=>"aaa" })
    #puts t.src
    assert_equal('<p id="realid">aaa</p>', result)
  end

  def test_amrita_id2
    html = '<p amrita_id="a" id="realid">sample_text</p><a href="xxx">yyy</a>'
    t = TemplateText.new(html)
    t.amrita_id = :amrita_id

    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal('<p id="realid">aaa</p><a href="xxx">yyy</a>', result)

    result = ""
    t.set_hint(HashData[:a=>ScalarData])
    t.expand(result, { :a=>"aaa" })
    #puts t.src
    assert_equal('<p id="realid">aaa</p><a href="xxx">yyy</a>', result)
  end

  def test_sanitize
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    result = ""
    t.expand(result, { :a=>"<xxx>&<yyy>" })
    assert_equal('<p>&lt;xxx&gt;&amp;&lt;yyy&gt;</p>', result)

    result = ""
    t.expand(result, { :a=>noescape { "<xxx>&<yyy>" }  })
    #puts t.src
    assert_equal('<p><xxx>&<yyy></p>', result)

    result = ""
    t.pre_format = true
    t.expand(result, { :a=>noescape { "<xxx>&<yyy>" }  })
    #puts t.src
    assert_equal('<p><xxx>&<yyy></p>', result)

    result = ""
    t.prettyprint = true
    t.expand(result, { :a=>noescape { "<xxx>&<yyy>" }  })
    #puts t.src
    assert_equal("\n<p><xxx>&<yyy></p>\n", result)
  end

  def test_sanitize2
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    result = ""
    t.expand(result, { :a=>"<xxx>&<yyy>" })
    assert_equal('<p>&lt;xxx&gt;&amp;&lt;yyy&gt;</p>', result)

    t = TemplateText.new(html)
    result = ""
    t.prettyprint = true
    t.expand(result, { :a=>"<xxx>&<yyy>" })
    assert_equal("\n<p>&lt;xxx&gt;&amp;&lt;yyy&gt;</p>\n", result)

    t = TemplateText.new(html)
    result = ""
    t.pre_format = true
    t.expand(result, { :a=>"<xxx>&<yyy>" })
    assert_equal('<p>&lt;xxx&gt;&amp;&lt;yyy&gt;</p>', result)
  end

  def test_template_cache1
    require "ftools"
    tempfile = "/tmp/amritatest#{$$}"
    cachedir = "/tmp/amritacache#{$$}"
    File::makedirs(cachedir)
    TemplateFileWithCache::set_cache_dir(cachedir)

    File.open(tempfile, "w") { |f| f.print <<-END }
    <p id="a">sample_text</p>
    END


    t = TemplateFileWithCache.new(tempfile)  
    assert_equal(SourceCache, t.cache_manager.type)
    t.use_compiler = true
    assert_equal(true, t.need_update?)
    result = ""
    t.expand(result, { :a=>"aaa" })
    sleep 1.1 # for test of need_update?
    assert_equal("    <p>aaa</p>\n", result)

    t = TemplateFileWithCache.new(tempfile)  
    t.use_compiler = true
    result = ""
    t.expand(result, { :a=>"aaa" })
    sleep 1.1 # for test of need_update?
    assert_equal("    <p>aaa</p>\n", result)


    File.open(tempfile, "w") { |f| f.print <<-END }
    <p id="a">sample_text</p>xxx
    END
    result = ""
    assert_equal(true, t.need_update?)
    t.expand(result, { :a=>"aaa" })
    assert_equal("    <p>aaa</p>xxx\n", result)
    assert_equal(false, t.need_update?)
  ensure
    #File.open(tempfile) { |f| puts f.read }
    File::unlink(tempfile)
    system "rm -r #{cachedir}"
  end

  def test_prettyprint
    html = '<body><p id="a">sample_text</p></body>'
    t = TemplateText.new(html)
    t.prettyprint = true
    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal("\n<body>\n  <p>aaa</p>\n</body>\n", result)

    def t.setup_taginfo
      ret = HtmlTagInfo.new
      ret[:body].pptype = 3
      ret[:p].pptype = 3
      ret
    end
    result = ""
    t.expand(result, { :a=>"aaa" })
    assert_equal("\n<body><p>aaa</p></body>\n", result)
  end

  def test_sanitizedstring
    html = '<p id="a">sample_text</p>'
    t = TemplateText.new(html)
    result = ""
    t.expand(result, { :a=>"<xxx>" })
    assert_equal('<p>&lt;xxx&gt;</p>', result)
    result = ""
    t.expand(result, { :a=>SanitizedString["<xxx>"] })
    assert_equal('<p><xxx></p>', result)

    html = '<p xxx="@aaa">sample_text</p>'
    t = TemplateText.new(html)
    t.expand_attr = true
    result = ""
    t.expand(result, { :aaa=>"<xxx>"} )
    assert_equal('<p xxx="&lt;xxx&gt;">sample_text</p>', result)
    result = ""
    t.expand(result, { :aaa=>SanitizedString['"<xxx>"']} )
    assert_equal('<p xxx=""<xxx>"">sample_text</p>', result)
  end

  def test_url_sanitizing
    html = '<a href="@a">sample_text</a>'
    xss = 'xxx">yyy</a><script>XSS</script><a href="zzz"'
    t = TemplateText.new(html)
    t.expand_attr = true
    result = ""
    t.expand(result, { :a=> xss})
    assert_equal('<a href="">sample_text</a>', result)
    result = ""
    t.expand(result, { :a=> SanitizedString[xss]})
    assert_equal('<a href="xxx">yyy</a><script>XSS</script><a href="zzz"">sample_text</a>', result)
  end

  def test_url_sanitizing2
    html = '<xmlelement aaa="@a">sample_text</xmlelement>'
    xss = 'javascritpt:XSS'
    t = TemplateText.new(html)
    t.expand_attr = true
    result = ""
    t.expand(result, { :a=> xss})
    assert_equal('<xmlelement aaa="javascritpt:XSS">sample_text</xmlelement>', result)

    result = ""
    def t.setup_taginfo
      ret = TagInfo.new
      ret[:xmlelement].set_url_attr(:aaa)
      ret
    end
    t.expand(result, { :a=> xss})
    assert_equal('<xmlelement aaa="">sample_text</xmlelement>', result)

    result = ""
    t.expand(result, { :a=> SanitizedString[xss]})
    assert_equal('<xmlelement aaa="javascritpt:XSS">sample_text</xmlelement>', result)

  end
  
  def test_xhtml
    xhtml1 = <<-END
<?XML version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- comment1 -->
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
<!-- comment2 -->
END

    t =  TemplateText.new xhtml1
    def t.setup_template
      super
      #p @template
    end

    result = ""
    t.expand(result, { :title=>'aaa', :body=>'bbb' })
    assert_equal(<<END, result)
<?XML version="1.0"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- comment1 -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>xhtml sample</title>
</head>
<body>
  <h1>aaa</h1>
  <p>bbb</p>
  <hr>
</body>
</html>
<!-- comment2 -->
END
  end

  def test_module_cache
    c = ModuleCache.new
    t = Time.new
    m = c.cache("aaa", :module, t) do 
      ret =  Module.new
      ret.module_eval <<-END
        def self::xxx
          123
        end
      END
      ret
    end

    assert_equal(123, m::xxx)
    assert_equal(m, c.get_item(:module, "aaa", nil).contents)
    assert_equal(123, c.get_item(:module, "aaa", nil).contents::xxx)
    assert_equal(nil, c.get_item(:source, "aaa", nil))
    assert_equal(nil, c.get_item(:module, "aaa", 123))
    m2 = c.cache("aaa", :module, t) { nil }
    assert_equal(m, m2)
    assert_equal(123, m2::xxx)

    m3 = c.cache("aaa", :module, t+1) { 789 }
    assert_equal(789, m3)

  end

  def test_source_cache
    tempdir = "/tmp/amritasrccache#{$$}"
    Dir::mkdir tempdir
    c = SourceCache.new(tempdir)
    t = Time.new - 1
    s = c.cache("aaa", :source, t) do
      "abcd"
    end
    assert_equal("abcd", s)
    s2 = c.cache("aaa", :source, t) { nil }
    assert_equal("abcd", s2)
    assert_equal(4321, c.cache("aaa", :source, t+1) { 4321 })
  ensure
    system "rm -r #{tempdir}"
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestTemplate.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestTemplate.new(method))
    end
  end
end

