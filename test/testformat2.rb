require 'runit/testcase'
require 'amrita/format'
require 'amrita/node_expand'


class TestFormat2 < RUNIT::TestCase
  include Amrita
  alias S format_inline

  def_tag :ul
  def_tag :li
  def_tag :img, :src, :alt

  def check(element, result)
    #expected = result.split("\n").collect{|s| s.strip}.join("\n")
    #actual = element.to_s.split("\n").collect{|s| s.strip}.join("\n")
    expected = result
    actual = element.to_s
    if expected != actual
      msg = ""
      msg.concat "expected:\n"
      msg.concat to_str(expected)
      msg.concat "\nbut was:\n"
      msg.concat to_str(actual)

      raise_assertion_error(msg, 2) 
    end
  end

  def test_element
    check(S { e("br") }, "<br>")
    check(S { e("p") {"aaa"}}, "<p>aaa</p>")

    e1 = Element.new(:a, a(:href, "index.html"), a(:id, "id11"), a(:class, "tagclass11"))
    e2 = Element.new(:hr)
    e3 = Element.new(:img, a(:src, "bg.gif"))
    assert_equal("a", e1.tagname)
    assert_equal(:a, e1.tagname_symbol)
    assert_equal("tagclass11", e1.tagclass)
    assert_nil(e2.tagclass)
    assert_nil(e3.tagclass)
    e2.put_attr(a(:size, "1"))
    assert_equal("1",e2[:size])
    assert_equal("1",e2["size"])
    e3 << a(:id, "e3x") << a(:class, "imgclass")
    assert_equal("e3x", e3.hid)
    e3 << a(:id, "e3") 
    assert_equal("e3", e3.hid)
    assert_equal("e3", e3[:id])
    assert_equal("e3", e3["id"])
    assert_equal("imgclass", e3.tagclass)
    assert_equal("imgclass", e3[:class])
    assert_equal("imgclass", e3["class"])
    e3[:class] = "imgclass1"
    assert_equal("imgclass1", e3.tagclass)
    assert_equal("imgclass1", e3[:class])
    assert_equal("imgclass1", e3["class"])
    e3[:id] = nil
    assert_equal(nil, e3.hid)

    assert_equal('<img src="bg.gif" class="imgclass1">', e3.to_s)
  end

  def test_attr
    assert_equal('<body background="bg.gif"></body>',
                 S { e("body", a(:background, "bg.gif"))} )
    assert_equal('<img src="a.gif" alt="alt text">',
                 S { e("img", a(:src, "a.gif"), a(:alt, "alt text"))} )
    assert_equal('<option selected></option>',
                 S { e("option", a(:selected))}  )

    a1 = Attr.new(:href, "index.html")
    a2 = Attr.new(:xxx)
    assert_equal("index.html", a1.value)
    assert_equal("href", a1.key)
    assert_equal(:href, a1.key_symbol)

    assert_equal('a(:href, "index.html")', a1.to_ruby)
    assert_equal('a(:xxx)', a2.to_ruby)
  end

  def test_href
    assert_equal(S { link("http://www.brain-tokyo.co.jp/") { "Brain" }},
      '<a href="http://www.brain-tokyo.co.jp/">Brain</a>')
  end

  def test_deftag
    assert_equal(S{ ul }, "<ul></ul>")
    assert_equal(S{ ul { li{"1"}}}, "<ul><li>1</li></ul>")
  end

  def test_array
    assert_equal(S{ ul { li{"1"} + li{"2"} }},   "<ul><li>1</li><li>2</li></ul>")
    assert_equal(S{ ul { [ li{"1"}, li{"2"} ]}}, "<ul><li>1</li><li>2</li></ul>")
    assert_equal(S{ ul {["1", "2"].collect {|n| li{n}}}}, "<ul><li>1</li><li>2</li></ul>")
    assert_equal(S{ ul {(1..2).collect {|n| li{n}}}}, "<ul><li>1</li><li>2</li></ul>")

    # test array with nil
    assert_equal(S{ ul {(0..2).collect {|n| if n > 0 then li{n} end }}}, "<ul><li>1</li><li>2</li></ul>")
  end

  def test_multi_line_formatter
    assert_equal("\n<ul>\n  <li>1</li>\n  <li>2</li>\n</ul>\n", format_pretty{ ul { li{"1"} + li{"2"} }} )
    assert_equal("\n<ul>\n  <li>1</li>\n  <li>2</li>\n</ul>\n", format_pretty{ ul {["1", "2"].collect {|n| li{n}}}})
  end

  def test_escape
    assert_equal(S {"<aa>"} ,"&lt;aa&gt;")
    assert_equal(S { noescape { "<aa>" } } ,"<aa>")
  end

  def test_span
    assert_equal('a',S { e(:span) { "a" } })
    assert_equal('<span align="center">a</span>',S { e(:span, a(:align, "center")) { "a" } })
  end

  def test_textarea
    assert_equal('<textarea>test</textarea>', S { e(:textarea) { "test" }})
    assert_equal('<textarea></textarea>', S { e(:textarea) })
  end

  def test_clone
    e = e(:a, a(:id, "zzz")) { "x"} 
    assert_equal('<a id="zzz">x</a>', e.clone.to_s)
    assert_equal('<a id="zzz">xxx</a>', e.clone{ "xxx" }.to_s)
  end



  def test_template1
    e = e(:a, a(:id, "zzz")) { "x"} 
    assert_equal('<a>x</a>', S {e.expand1(true)})
    assert_equal("", S {e.expand1(false)})
    assert_equal('<a>ZZZ</a>', S {e.expand1({ :zzz => "ZZZ"})})
    assert_equal('<a>1</a><a>2</a><a>3</a>', S {e.expand1([1,2,3])})
  end

  def test_template2
    e = NodeArray.new([ e(:b, a(:id, "zzz")) { "x"}, e(:c, a(:id, "xxx")) { "y" } ])
    assert_equal('<b id="zzz">x</b><c id="xxx">y</c>', S {e.expand1(true)})
    assert_equal("", S {e.expand1(false)})
    assert_equal('<b>aaa</b><c>1</c>', 
		 S {e.expand1( { :zzz => "aaa", :xxx => 1 })})
  end

  def test_template3
    e = e(:a) { [e(:b, a(:id, "zzz")) { "x"}, e(:c, a(:id, "xxx")) { "y" } ] }
    assert_equal('<a><b id="zzz">x</b><c id="xxx">y</c></a>', S {e.expand1(true)})
    assert_equal("", S {e.expand1(false)})
    assert_equal('<a><b>aaa</b><c>1</c></a><a><b>bbb</b><c>2</c></a><a><b>ccc</b><c>3</c></a>', 
		 S {e.expand1([
			       { :zzz => "aaa", :xxx => 1 },
			       { :zzz => "bbb", :xxx => 2 },
			       { :zzz => "ccc", :xxx => 3 },
			     ])})
  end

  def test_add
    e1 = e(:x) { "xxx" }
    assert_equal('[ e(:x) { "xxx" }, "1" ]', (e1 + 1).to_ruby)
    assert_equal('[ e(:x) { "xxx" }, "aaa" ]', (e1 + "aaa").to_ruby)
    assert_equal('[ e(:x) { "xxx" }, e(:x) { "xxx" } ]', (e1 + e1).to_ruby)
    assert_equal('e(:x) { "xxx" }', (Null + e1).to_ruby)
  end

  def test_expand_by_proc1
    e = e(:x) { "xxx" }

    data = proc { |e, context| e[:a] = "b"; e }
    assert_equal('<x a="b">xxx</x>', e.expand1(data).to_s)
  end

  def test_expand_by_proc2
    e = e(:li) { "x" }

    data = (0..5).collect do |i|
      if i%2 == 0
	proc { |e, context| e[:color] = "blue"; e.expand1(i, context) }
      else
	proc { |e, context| e[:color] = "red"; e.expand1(i, context) }
      end
    end
    assert_equal('
<li color="blue">0</li>
<li color="red">1</li>
<li color="blue">2</li>
<li color="red">3</li>
<li color="blue">4</li>
<li color="red">5</li>'.gsub("[\r\n]", ""), e.expand1(data).to_s.gsub("[\r\n]", ""))
  end

  def test_filter
    e1 = e(:x) { "xxx" } 
    e1.each do |ee|
      ee.init_body { e(:y) { ee.body } }
    end
    assert_equal('e(:x) { e(:y) { "xxx" } }', e1.to_ruby)    


    e2 = e(:z) { [ e(:x) { "xxx" } ,e(:x) { "xxx" } ] }
    e2.each do |ee|
      if ee.tagname == "x"
	ee.set_tag(:y)
      end
    end
    assert_equal('e(:z) { [ e(:y) { "xxx" }, e(:y) { "xxx" } ] }', e2.to_ruby)    
  end

  def test_elementarray
    eary = NodeArray.new
    e = Element.new(:select)
    e.init_body do
      yaary = NodeArray.new
      yae = Element.new(:option)
      yaary << yae
      yaary
    end
    eary << e

    size = 0 
    eary.each_element { |e| size += 1 }
    assert_equal(2, size)
  end

  def test_expand_attr
    context = ExpandContext.new
    context.expand_attr = true
    e1 = e(:a, :href=>"@aaa") { "xxx"}
    assert_equal('<a href="@aaa">xxx</a>', e1.to_s)
    assert_equal('<a href="bbb">xxx</a>', e1.expand({:aaa=>"bbb"}, context).to_s)
    assert_equal('<a href="@aaa">xxx</a>', e1.to_s)
  end		
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestFormat2.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestFormat2.new(method))
    end
  end
end

