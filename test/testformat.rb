require 'runit/testcase'
require 'amrita/format'
require 'amrita/node_expand'
require 'amrita/parser'

$print_result = false

class TestFormat < RUNIT::TestCase
  include Amrita
  Html1 = <<-END
<html>

<body>
<h1 id="title">title will be inserted here</h1>
<p id="body">body text will be inserted here</p>
</body>

</html>
END

  XHtml1 = <<-END
<?XML version="1.0"?>
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

  def test_formatter
    ret = ""
    f = Formatter.new(ret)
    assert_equal('x="1"', f.format_attrs(a(:x, 1)))
    assert_equal('x="1" y="2"', f.format_attrs(a(:x, 1, :y, 2)))
    e = e(:abc,a(:x, 1, :y, 2))
    assert_equal('<abc x="1" y="2">', f.format_start_tag(e))
    assert_equal('</abc>', f.format_end_tag(e))
    assert_equal('<abc x="1" y="2">', f.format_single_tag(e))
    f.asxml = true
    assert_equal('<abc x="1" y="2" />', f.format_single_tag(e))
  end

  def test_asisformatter
    tmpl = HtmlParser.parse_text Html1
    ret = ""
    f = AsIsFormatter.new(ret)
    f.format(tmpl)
    assert_equal(Html1, ret)

    tmpl = HtmlParser.parse_text XHtml1
    ret = ""
    f = AsIsFormatter.new(ret)
    f.asxml = true
    f.format(tmpl)
    assert_equal(XHtml1, ret)
  end

  def test_singlelineformatter
    tmpl = HtmlParser.parse_text Html1
    ret = ""
    f = SingleLineFormatter.new(ret)
    f.format(tmpl)
    assert_equal('<html> <body> <h1 id="title">title will be inserted here</h1> <p id="body">body text will be inserted here</p> </body> </html> ', ret)
  end

  def test_prettyprintformatter
    tmpl = HtmlParser.parse_text Html1
    ret = ""
    f = PrettyPrintFormatter.new(ret)
    f.format(tmpl)
    assert_equal(<<END, ret)

<html> 
  <body> 
    <h1 id="title">title will be inserted here</h1> 
    <p id="body">body text will be inserted here</p> 
  </body> 
</html> 
END
  end

  def test_attr_filter
    tmpl = HtmlParser.parse_text '<p __id="aaaa" klass="xyz">xxxxx</p>'
    ret = ""
    f = SingleLineFormatter.new(ret)
    f.set_attr_filter(:__id=>:id, :klass=>:class)
    assert_equal('id="xxx"', f.format_attrs(a(:__id=>"xxx")))
    f.format(tmpl)
    assert_equal('<p id="aaaa" class="xyz">xxxxx</p>', ret)
  end

  def w3m(str)
    %x[echo #{str.inspect} | w3m -T text/html -dump].chomp
  end

  def test_sanitizer
    assert_equal("abc", Sanitizer::sanitize_text("abc"))
    assert_equal("efg", Sanitizer::sanitize_attribute_value("efg"))
    assert_equal("hij", Sanitizer::sanitize_url("hij"))

    assert_equal("&lt;abc&gt;", Sanitizer::sanitize_text("<abc>"))
    assert_equal("<abc>", w3m(Sanitizer::sanitize_text("<abc>")))
    assert_equal("a &amp; b", Sanitizer::sanitize_text("a & b"))
    assert_equal("a & b", w3m(Sanitizer::sanitize_text("a & b")))

    assert_equal('&lt;x a=&quot;xyz&quot;&gt;&#39;&lt;/x&gt;', 
                 Sanitizer::sanitize_attribute_value('<x a="xyz">\'</x>'))
    assert_equal('<x a="xyz">\'</x>', w3m(Sanitizer::sanitize_attribute_value('<x a="xyz">\'</x>')))

    assert_equal('http://www.ruby-lang.org/', Sanitizer::sanitize_url("http://www.ruby-lang.org/")) 
    assert_equal('https://www.ruby-lang.org/', Sanitizer::sanitize_url("https://www.ruby-lang.org/")) 
    assert_equal('ftp://www.ruby-lang.org/', Sanitizer::sanitize_url("ftp://www.ruby-lang.org/")) 
    assert_equal('http://www.ruby-lang.org/#', Sanitizer::sanitize_url("http://www.ruby-lang.org/#")) 
    assert_equal(nil, Sanitizer::sanitize_url("javascript://www.ruby-lang.org/")) 
    assert_equal(nil, Sanitizer::sanitize_url("about://www.ruby-lang.org/")) 
    assert_equal('&#39;&', Sanitizer::sanitize_url("'&")) 
    assert_equal("'aaa'&'bbb'", w3m(Sanitizer::sanitize_url("'aaa'&'bbb'")))

    nbsp_str= 'a&nbsp;b'
    assert_equal(nbsp_str, nbsp_str.amrita_sanitize)
    assert_equal(nbsp_str, nbsp_str.amrita_sanitize_as_attribute)
    assert_equal('a b', w3m(nbsp_str.amrita_sanitize))
  end

  def test_sanitizer2
    tmpl = HtmlParser.parse_text '<a id="aaaa">xx</a>'
    xss_atack1 = %q[http://www.ruby-lang.org/"><script>alert('hello')</script>] #"
    s = format_inline({
                        :aaaa=>a(:href=>xss_atack1) { "<x>&" },
                      }) { tmpl }

    assert_equal('<a href="">&lt;x&gt;&amp;</a>', s)

    xss_atack2 = %q[javascript:alert('hello')]
    s = format_inline({
                        :aaaa=>a(:href=>xss_atack2) { "xxxx" },
                      }) { tmpl }
    assert_equal('<a href="">xxxx</a>', s)

    tmpl_img = HtmlParser.parse_text '<img id="aaaa">'
    s = format_inline({
                        :aaaa=>a(:src=>xss_atack1)
                      }) { tmpl_img }

    assert_equal('<img src="">', s)

    s = format_inline({
                        :aaaa=>a(:src=>xss_atack2)
                      }) { tmpl_img }

    assert_equal('<img src="">', s)

  end

  def test_sanitizer3
    tmpl = HtmlParser.parse_text '<x id="aaaa">xxx</x>'
    
    s = format_inline( { :aaaa=> '<yyy>' }) { tmpl }
    assert_equal('<x>&lt;yyy&gt;</x>', s)

    # disabel sanitizer by noescape
    s = format_inline( { :aaaa=> noescape { '<yyy>' } }) { tmpl }
    assert_equal('<x><yyy></x>', s)

    x = '<x a="xyz">\'</x>'
    assert_equal('&lt;x a=&quot;xyz&quot;&gt;&#39;&lt;/x&gt;', x.amrita_sanitize_as_attribute)
    t = HtmlParser.parse_text x.amrita_sanitize_as_attribute
    assert_equal(x, noescape { t }.to_s)
    assert_equal(x.amrita_sanitize, format_inline { t } )

    s = format_inline { e(:xxx) { x } }
    t = HtmlParser.parse_text s
    assert_equal(e(:xxx) { x }, t)
  end

  def test_sanitizedstring
    s1 = "<xxx>"
    assert_equal("&lt;xxx&gt;", format_inline{s1})
    assert_equal("<xxx>", format_inline{SanitizedString[s1]})
  end

  def test_preformat1
    tmpl = HtmlParser.parse_text "<p>xxxx</p>"
    f = AsIsFormatter.new(nil)
    r = tmpl.pre_format(f).result
    assert(r.kind_of?(Amrita::SanitizedString))
    assert_equal('<p>xxxx</p>', r)

    tmpl = HtmlParser.parse_text "<p id=x>xxxx</p>"
    f = AsIsFormatter.new(nil)
    r = tmpl.pre_format(f).result
    assert_equal(Element, r.class)
    assert_equal('e(:p,a(:id, "x")) { "xxxx" }', r.to_ruby)

    tmpl = HtmlParser.parse_text "<p>xxxx</p><p id=x>yyyy</p>"
    f = AsIsFormatter.new(nil)
    r = tmpl.pre_format(f).result
    assert_equal(Array, r.class)
    assert_equal('<p>xxxx</p>', r[0])
    assert_equal('e(:p,a(:id, "x")) { "yyyy" }', r[1].to_ruby)

    tmpl = HtmlParser.parse_text "<p id=x>xxxx</p><p>yyyy</p>"
    f = AsIsFormatter.new(nil)
    r = tmpl.pre_format(f).result
    assert_equal(Array, r.class)
    assert_equal('e(:p,a(:id, "x")) { "xxxx" }', r[0].to_ruby)
    assert_equal('<p>yyyy</p>', r[1])

    tmpl = HtmlParser.parse_text "xxx<em>yyy</em>zzz"
    f = AsIsFormatter.new(nil)
    r = tmpl.pre_format(f).result
    assert_equal(Amrita::SanitizedString, r.class)
    assert_equal('xxx<em>yyy</em>zzz', r)

    tmpl = HtmlParser.parse_text "<p id=x>xxx<em>yyy</em>zzz</p>"
    f = AsIsFormatter.new(nil)
    r = tmpl.pre_format(f).result
    assert_equal(Element, r.class)
    assert_equal('xxx<em>yyy</em>zzz', r.body.to_s)
  end

  def check_preformat(formatter, node, data=nil)
    ans = ""
    if data
      formatter.format(node.expand(data), ans)
    else
      formatter.format(node, ans)
    end

    result = ""
    pre = node.pre_format(formatter).result_as_top
    if data
      formatter.format(pre.expand(data), result)
    else
      formatter.format(pre, result)
    end
    if $print_result
      puts "------------------------------------"
      print result
      puts "\n------------------------------------"
    end
    assert_equal(ans, result)

    # pre_formating nodes already pre_formatted should make same result
    result2 = ""
    pre = pre.pre_format(formatter).result_as_top
    formatter.format(pre, result2)
  end

  def test_preformat2
    tmpl = HtmlParser.parse_text Html1
    check_preformat(AsIsFormatter.new, tmpl)
    check_preformat(SingleLineFormatter.new, tmpl)
    assert_exception(RuntimeError) { check_preformat(PrettyPrintFormatter.new, tmpl) }
  end

  def test_preformat3
    tmpl = HtmlParser.parse_text Html1
    data = { :title=>"title", :body=>"pre_format test" }
    check_preformat(AsIsFormatter.new, tmpl, data)
    check_preformat(SingleLineFormatter.new, tmpl)
  end

  def test_preformat_with_expand_attr
    f = AsIsFormatter.new
    tmpl = HtmlParser.parse_text '<a href="@xxx">yyy</a>'

    pre = tmpl.pre_format(f).result
    assert_equal(Amrita::SanitizedString, pre.class)
    assert_equal('<a href="@xxx">yyy</a>', pre)

    pre = tmpl.pre_format(f, true).result
    assert_equal(Amrita::Element, pre.class)
    assert_equal(e(:a,a(:href, "@xxx")) { "yyy" }, pre)

    data = { :xxx=>"http://www.ruby-lang.org/" }
    assert_equal(e(:a,a(:href, "@xxx")) { "yyy" }, pre.expand(data))
    assert_equal(tmpl.expand(data), pre.expand(data))

    context = Amrita::ExpandContext.new
    context.expand_attr = true
    assert_equal(e(:a,a(:href, "http://www.ruby-lang.org/")) { "yyy" }, pre.expand(data, context))
    assert_equal(tmpl.expand(data, context), pre.expand(data, context))
  end

  def test_taginfo
    tmpl = HtmlParser.parse_text Html1
    ret = ""
    f = PrettyPrintFormatter.new(ret)
    f.format(tmpl)
    assert_equal(<<END, ret)

<html> 
  <body> 
    <h1 id="title">title will be inserted here</h1> 
    <p id="body">body text will be inserted here</p> 
  </body> 
</html> 
END
    taginfo = HtmlTagInfo.new
    taginfo[:p].pptype = 1
    ret = ""
    f = PrettyPrintFormatter.new(ret,taginfo)
    f.format(tmpl)
    assert_equal(<<END, ret)

<html> 
  <body> 
    <h1 id="title">title will be inserted here</h1> 
    <p id="body">body text will be inserted here
    </p> 
  </body> 
</html> 
END

    taginfo = TagInfo.new
    taginfo[:html].pptype = 1
    taginfo[:body].pptype = 2
    ret = ""
    f = PrettyPrintFormatter.new(ret,taginfo)
    f.format(tmpl)
    assert_equal(<<END, ret)

<html> 
  <body> <h1 id="title">title will be inserted here</h1> <p id="body">body text will be inserted here</p> </body> 
</html> 
END
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestFormat.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestFormat.new(method))
    end
  end
end

