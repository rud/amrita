
require 'runit/testcase'
require 'amrita/parser'
require 'amrita/node_expand'
require 'amrita/format'


class TestHtmlParser < RUNIT::TestCase
  include Amrita

  Tag = HtmlScanner::TagInline

  def scan(text)
    begin
      ret = []
      HtmlScanner.scan_text(text) do | state, token|
	ret << token
      end
    end
    ret
  end

  def parse(text)
    HtmlParser.parse_text(text)
  end

  def test_scanner
    assert_equal(Tag.new("html"), Tag.new("html"))
    assert_equal([Tag.new("em"), "xxx", Tag.new("/em")], scan("<em>xxx</em>"))
    assert_equal([Tag.new("img", [["src", "xxx.gif"]])], scan("<img src=xxx.gif>"))
    assert_equal([Tag.new("a",[["href", "http://www.brain-tokyo.co.jp/"]])],
		 scan('<a href="http://www.brain-tokyo.co.jp/">'))
    h = <<END
<table border="1" align="center" width="95%" bgcolor="#CCFFCC">
  <tr>
     <td>
        <a name="28077">[2:3]    
        <b>mailtoのテスト</b>
        <dl>
            <dt>1名前： <a href="mailto:tnaka@brain-tokyo.com">中島</a>  投稿日： Fri Jan 26 19:00:25 JST 2001<dd><br></dd></dt>
            <dt>2名前： <a href="mailto:">ななしさん</a>  投稿日： Fri Jan 26 19:00:33 JST 2001<dd> <br></dd></dt>
            <dt>3名前： <a href="mailto:">ななしさん</a>  投稿日： Fri Jan 26 19:00:44 JST 2001<dd>されたみたい <br>
        </dl>
     </td>
  </tr>
</table>
END
    assert_equal(
		 [
		   Tag.new("table", [["border", "1"], ["align", "center"], ["width", "95%"], ["bgcolor", "#CCFFCC"]]), 
		   "\n     ", 
		   Tag.new("a", [["name", "28077"]])
		 ],
		 scan(h).values_at(0,3,6))
  end

  def parse_and_print(t)
    n = parse(t)
    puts ""
    puts n.to_ruby
    puts "\n------------------------------"
    print M { n  }
    puts "\n------------------------------"
  end

  def test_parser
    assert_equal('e(:p) { "abc" }',parse("<p>abc</p>").to_ruby)

    assert_equal('e(:head) { e(:title) { "abc" } }',
		 parse("<head><title>abc</title></head>").to_ruby)

    assert_equal('e(:html) { [ e(:head) { e(:title) { "abc" } }, e(:body) { e(:p) { "abc" } } ] }',
		 parse("<html><head><title>abc</title></head><body><p>abc</p></body></html>").to_ruby)
    assert_equal('e(:x,a(:a, "1"),a(:b)) { " " }',
		 parse("<x a = 1 b > </x>").to_ruby)

    h = <<END
  <tr>
     <td>
        <a name="28077">[2:3]    </a>
        <b>mailtoのテスト</b>
        <dl>
            <dt>3名前： <a href="mailto:">ななしさん</a> 投稿日： Fri Jan 26 19:00:44 JST 2001されたみたい <br></dt>
            <dt>3名前： <a href="mailto:">ななしさん</a> 投稿日： Fri Jan 26 19:00:44 JST 2001されたみたい <br></dt>
        </dl>
     </td>
  </tr>
</table>
END
    #parse_and_print(h)

    assert_equal('special_tag("%=", " Time.new ") ',
		 parse('<%= Time.new %>').to_ruby)
    assert_equal('<%= Time.new %>',
		 parse('<%= Time.new %>').to_s)
    assert_equal('<!-- comment -->',
		 parse('<!-- comment -->').to_s)
    assert_equal('<!-- comment-with-dash -->',
                 parse('<!-- comment-with-dash -->').to_s)
    assert_equal('<!-- <x> -->',
		 parse('<!-- <x> -->').to_s)
#    assert_equal('<?xml version="1.0" encoding="Shift_JIS"?>',
#		 parse('<?xml version="1.0" encoding="Shift_JIS"?>').to_s)
    assert_equal('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
		 parse('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">').to_s)

    assert_equal('<meta http-equiv="Content-Type" content="text/html;CHARSET=EUC-JP">',
		 parse('<meta http-equiv="Content-Type" content="text/html;CHARSET=EUC-JP">').to_s)
  end

  def test_parser2
    assert_equal('e(:ul) { e(:li) { "abc" } }',parse("<ul><li>abc</li></ul>").to_ruby)
    assert_equal('e(:ul) { [ e(:li) { "abc" }, e(:li) { "efg" }, e(:li) { "xyz" } ] }',
		 parse("<ul><li>abc</li><li>efg</li><li>xyz</li></ul>").to_ruby)
    assert_equal('e(:ul) { [ e(:li) { "abc" }, e(:li) { "efg" }, e(:li) { "xyz" } ] }',
		 parse("<ul><li>abc</li><li>efg</li><li>xyz</ul>").to_ruby)
    assert_equal('e(:ul) { [ e(:li) { "abc" }, e(:li) { "efg" }, e(:li) { "xyz" } ] }',
		 parse("<ul><li>abc<li>efg</li><li>xyz</ul>").to_ruby)
    assert_equal('e(:ul) { [ e(:li) { "abc" }, e(:li) { "efg" }, e(:li) { "xyz" } ] }',
		 parse("<ul><li>abc<li>efg<li>xyz</ul>").to_ruby)
    assert_equal('[ e(:p) { "a" }, e(:p) { "b" } ]',
		 parse("<p>a<p>b").to_ruby)
    assert_equal('e(:dl) { [ e(:dt) { "a" }, e(:dd) { "b" }, e(:dd) { "c" } ] }',
		 parse("<dl><dt>a<dd>b<dd>c").to_ruby)

    #assert_equal('[ e(:p) { [ "a", e(:em) { "b" }, "c" ] }, e(:br) , e(:hr) , e(:p) { "x" } ]',

    assert_equal('[ e(:p) { [ "a", e(:em) { "b" }, "c", e(:br)  ] }, e(:hr) , e(:p) { "x" } ]',
		 parse("<p>a<em>b</em>c<br><hr><p>x").to_ruby)
    assert_equal('e(:table) { e(:tr) { e(:td) { e(:p) { "a" } } } }',
		 parse("<table><tr><TD><P>a</table>").to_ruby)
    assert_equal('e(:table) { e(:tbody) { e(:tr) { e(:td) { e(:p) { "a" } } } } }',
		 parse("<table><tbody><tr><TD><P>a</table>").to_ruby)

    template_text = <<END
<!-- start of template ------------->
<html>
<head>
  <title id="title">title</title>
</head>
<body>
<h1 id="title">title</h1>
  <ul>
  <li id=list> </li>
  </ul>
</body>
</html>
END
      assert_equal('[ ' + 
                   'special_tag("!--", " start of template -----------") , "\n", ' + 
                   'e(:html) { [ "\n", e(:head) { [ "\n  ", e(:title,a(:id, "title")) { "title" }, "\n" ] }, "\n", ' +
                   'e(:body) { [ "\n", e(:h1,a(:id, "title")) { "title" }, "\n  ", e(:ul) { [ "\n  ", e(:li,a(:id, "list")) { " " }, "\n  " ] }, "\n" ] }, "\n" ] }, "\n" ]',
                   parse(template_text).to_ruby)
  end

  def test_parser_error
    assert_exception(HtmlParseError) { parse('<x></x></y>') }
    assert_exception(HtmlParseError) { parse('<x></x></y>') }
    assert_exception(HtmlParseError) { parse('<ul><ul>a</ul><li></ul></ul>')}
    assert_exception(HtmlParseError) { parse('<table><tr></ul><li></ul></ul>')}
    assert_exception(HtmlParseError) { parse('<p>a<a>aa</p><p>') }
  end

  def test_expander1
    template = "<h1 id='title'>xx</h1>"
    d = { :title => "expand title" }
    assert_equal('<h1>expand title</h1>',
		 format_inline(d) { e(:h1, a(:id, "title") { "xx" }) })
    assert_equal('<h1>expand title</h1>',
		 format_inline(d) { parse(template) })

    s1 = Struct.new("SS", :title)
    d = s1.new("struct title")
    d.extend ExpandByMember
    
    assert_equal('<h1>struct title</h1>',
		 format_inline(d) { parse(template) })

  end

  class S1 < Struct.new("S1", :name, :email)
    include Amrita::ExpandByMember
  end

  def test_expander2
    template = "<h1 id='title1'>xx</h1><h2 id='title2'>zz</h2>"
    d = { :title1 => "expand title1" , :title2 => "expand title2"}
    assert_equal('<h1>expand title1</h1><h2>expand title2</h2>',
		 format_inline(d) { parse(template) })
    d = { :title1 => (e(:em) { "expand title1" } ), :title2 => "expand title2"}
    assert_equal('<h1><em>expand title1</em></h1><h2>expand title2</h2>',
    		 format_inline(d) { parse(template) })

    template = "<ul><li id='list'><span id='name'>name</span> <span id='email'></span></li></ul>"

    d = { :list => [ 
	{ :name => 'aaa', :email => 'aaa@xxx' },
	{ :name => 'bbb', :email => 'bbb@xxx' },
	{ :name => 'ccc', :email => 'ccc@xxx' },
      ]
    }

    assert_equal(
		 '<ul>' +
		 '<li>aaa aaa@xxx</li>' +
		 '<li>bbb bbb@xxx</li>' +
		 '<li>ccc ccc@xxx</li>' +
		 '</ul>',
		 format_inline(d) { parse(template) })

#    puts gen_html_multi(d) { parse(template) }
#    puts format_inline(d) { parse(template) }


    d = { :list => 
      [
	S1.new("aaa","aaa@xxx"),
	S1.new("bbb","bbb@xxx"),
	S1.new("ccc","ccc@xxx")
      ]
    }
    assert_equal(
		 '<ul>' +
		 '<li>aaa aaa@xxx</li>' +
		 '<li>bbb bbb@xxx</li>' +
		 '<li>ccc ccc@xxx</li>' +
		 '</ul>',
		 format_inline(d) { parse(template) })
    

  end

  def test_expander3
    template =  "<ul><li id='list1'><span id='name'>name</span> <span id='email'>email</span></li></ul>"
    template += "<ol><li id='list2'><span id='name'>name</span> <span id='email'>email</span></li></ol>"
    #puts parse(template).to_ruby
    d = { :list1 => 
      [
	S1.new("aaa","aaa@xxx"),
	S1.new("bbb","bbb@xxx"),
      ],
      :list2 => 
      [
	S1.new("xxx","xxx@zzz"),
	S1.new("yyy","yyy@zzz"),
      ]
    }
    assert_equal(
		 '<ul>' +
		   '<li>aaa aaa@xxx</li>' +
		   '<li>bbb bbb@xxx</li>' +
		 '</ul>' +
		 '<ol>' +
		   '<li>xxx xxx@zzz</li>' +
		   '<li>yyy yyy@zzz</li>' +
		 '</ol>',
		 format_inline(d) { parse(template) })

  end

  def test_prettyprint

    s = ""
    f = PrettyPrintFormatter.new(s)
    f.format(parse('<ul><li>aaa</li></ul>'))
    assert_equal("\n<ul>\n  <li>aaa</li>\n</ul>\n", s)

    s = ""
    f = PrettyPrintFormatter.new(s)
    f.format(parse("\n<ul>\n<li>aaa bbb</li>\n</ul>\n"))
    assert_equal(" \n<ul> \n  <li>aaa bbb</li> \n</ul> \n", s)


    html = <<END
<head>
<title>walrusのサンプル</title>
</head>
END
    s = ""
    f = PrettyPrintFormatter.new(s)
    f.format(parse(html))

    result = <<END

<head> 
  <title>walrusのサンプル</title> 
</head> 
END
    assert_equal(result, s)
  end

  def test_proc
    template = HtmlParser.parse_inline <<-END
    <table id=table1>
      <tr id=header><th>col1</th><th>col2</th></tr>
      <tr id=line1 color="red"> <td id=col11><td id=col12></tr>
      <tr id=line2 color="blue"><td id=col21><td id=col22></tr>
    </table>
    END

    colomun_data = [[ "aa", "bb"], ["cc", "dd"], ["ee", "ff"], ["gg", "hh"]]
    
    data = {
      :table1 => proc do |table, context|
	h = table.find { |e|  e.hid == "header" }
	l1 = table.find { |e| e.hid == "line1" }
	l2 = table.find { |e| e.hid == "line2" }
	l1.delete_attr!(:id)
	l2.delete_attr!(:id)

	ret = [ h ]
	colomun_data.each_with_index do |d, i|
	  if i%2 == 0
	    ret << l1.expand({ :col11 => d[0], :col12 => d[1] }, context)
	  else
	    ret << l2.expand({ :col21 => d[0], :col22 => d[1] }, context)
	  end
	end
	ret
      end
    }

    result = <<END
 
<tr id="header">
<th>col1</th>
<th>col2</th>
</tr>
<tr color="red"> 
<td>aa</td>
<td>bb</td>
</tr>
<tr color="blue">
<td>cc</td>
<td>dd</td>
</tr>
<tr color="red"> 
<td>ee</td>
<td>ff</td>
</tr>
<tr color="blue">
<td>gg</td>
<td>hh</td>
</tr> 
END
     s = ""
     f = PrettyPrintFormatter.new(s)
     f.format(template.expand(data))
     assert_equal(result, s)
  end

  def test_dt
    template = HtmlParser.parse_inline <<-END
    <dl>
      <dt>1<dd>2<dt>3<dd>4<dt>5<dd>6
    </dl> 
    END

    assert_equal(" <dl> <dt>1</dt><dd>2</dd><dt>3</dt><dd>4</dd><dt>5</dt><dd>6 </dd></dl> ", template.to_s)
  end

  def test_pre
    pre_text = <<-END
    <pre id="xxx">
1
 2
  3
 4
5
    </pre> 
    END
    template = HtmlParser.parse_text(pre_text)
    assert_equal(pre_text.strip, template.to_s.strip)
    d = { 
      :xxx=> CompactSpace.new(false) { "\nabc\nefg\n" }
    }
    assert_equal(' <pre>
abc
efg
</pre> ', template.expand(d).to_s)
    assert_equal(pre_text.strip, template.to_s.strip)
  end

  def test_noescape
    template = HtmlParser.parse_inline <<-END
    <ul>
      <li id=list>
    </ul> 
    END

    d = {
      :list => [
        "aaaa",
        e(:span) { [ "bbbb", e(:br), "cccc" ] }, 
        noescape { "dddd<br>eeee" }
      ]
    }

    assert_equal("<ul><li>aaaa</li><li>bbbb<br>cccc</li><li>dddd<br>eeee</li></ul>", 
                 template.expand(d).to_s.gsub(/\s/, ""))
  end

  def test_attrarray
    template = HtmlParser.parse_inline <<-END
      <body id=body>
        <table id=table>
          <tr id=list><td id=xxx><td id=yyy></tr>
        </table>
      </body>
    END


    d = { 
      :body=>a(:bgcolor,"blue", :text, "red") {
        { 
          :table=>a(:border, 1) {
            {
              :list=> [
                { :xxx=>"x1", :yyy=>"y1" },
                { :xxx=>"x2", :yyy=>"y2" },
              ]
            }
          }
        }
      }
    }

    assert_equal((<<END).gsub(/\s/, ""),    template.expand(d).to_s.gsub(/\s/, ""))
      <body bgcolor="blue" text="red">
        <table border="1">
          <tr>
            <td>x1</td>
            <td>y1</td>
          </tr><tr>
            <td>x2</td>
            <td>y2</td>
          </tr>
        </table>
      </body>
END

  end

  def test_filter
    tmpl = HtmlParser.parse_text('<p><span walrus=x></span></p>') do |e| 
      if e[:walrus]
        e[:id] = e[:walrus]
        e.delete_attr!(:walrus)
      end
      e
    end
    assert_equal('<p><span id="x"></span></p>', tmpl.to_s)
  end

  def test_escaped_char
    assert_equal('<>&"',parse("&lt;&gt;&amp;&quot;").to_s)
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestHtmlParser.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestHtmlParser.new(method))
    end
  end
end

