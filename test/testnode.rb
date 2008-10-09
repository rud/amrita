require 'runit/testcase'
require 'amrita/node'

class TestNode < RUNIT::TestCase
  include Amrita

  def test_attr
    a = Attr.new("key", "value")
    assert_equal("key", a.key)
    assert_equal(:key, a.key_symbol)
    assert_equal("value", a.value)
    assert_equal('a(:key, "value")', a.to_ruby)

    a = Attr.new(:key, 123)
    assert_equal("key", a.key)
    assert_equal(:key, a.key_symbol)
    assert_equal("123", a.value)

    assert_equal(true, a == a)
    assert_equal(true, a ==  Attr.new(:key, 123))
    assert_equal(true, a ==  Attr.new(:key, "123"))
    assert_equal(true, a ==  Attr.new(:key, 100+23))
    assert_equal(false, a ==  Attr.new(:key, "v"))
    a.value = "v"
    assert_equal(true, a ==  Attr.new(:key, "v"))
  end

  def test_init
    e = Element.new("x")
    assert_equal("x", e.tagname)

    e = Element.new("x", :y=>"z")
    assert_equal("x", e.tagname)
    assert_equal("z", e[:y])

    e = Element.new("x", Attr.new(:y,"z"))
    assert_equal("x", e.tagname)
    assert_equal("z", e[:y])

    e = Element.new("x", :y=>"z") { "body" }
    assert_equal("x", e.tagname)
    assert_equal("z", e[:y])
    assert_equal('"body"', e.body.to_ruby)
  end

  def test_element
    e = Element.new("x")
    assert_equal("x", e.tagname)
    e.set_tag(:xx)
    assert_equal("xx", e.tagname)
    assert_equal(:xx, e.tagname_symbol)
    assert_nil(e.hid)
    e[:id] = "1234"
    assert_equal("1234", e.hid)
    assert_nil(e.tagclass)
    e[:class] = "4567"
    assert_equal("4567", e.tagclass)

    e = (Element.new("x") << Attr.new(:id, 1234) << Attr.new(:class, 4567))
    assert_equal("x", e.tagname)
    assert_equal("1234", e.hid)
    assert_equal("4567", e.tagclass)

    assert_equal(false, e.include_attr?(:xxx))
    assert_equal(true, e.include_attr?(:class))

    e.delete_attr!(:class)
    assert_nil(e.tagclass)

    e.set_text("abc")
    assert_equal('e(:x,a(:id, "1234")) { "abc" }', e.to_ruby)

    assert_equal(false, e.no_child?)
    assert_equal(true, e(:x).no_child?)
  end

  def test_elementarray
    c1 = Element.new("child1")
    c2 = Element.new("child2")
    p = Element.new(:parent) { [ c1, c2] }
    assert_equal('e(:parent) { [ e(:child1) , e(:child2)  ] }', p.to_ruby)
    a = p.body + Element.new("child3")
    assert_equal('[ e(:child1) , e(:child2) , e(:child3)  ]', a.to_ruby)
    assert_equal('e(:parent) { [ e(:child1) , e(:child2)  ] }', p.to_ruby)
    p.body << Element.new("child3")
    assert_equal('e(:parent) { [ e(:child1) , e(:child2) , e(:child3)  ] }', p.to_ruby)

    x = [];  p.each_element { |e| x << e.tagname_symbol }
    assert_equal([:parent, :child1, :child2, :child3], x)
  end


  def test_attrarray
    a1 = a(:xx=>11)
    assert_equal("a(:xx, 11)", a1.to_ruby)
    assert_equal("a(:xx, 11)", eval(a1.to_ruby).to_ruby)
    a1 = a(:xx=>11, :yy=>22)
    assert_equal(2, a1.size())
    a1.each do |a|
      case a.key_symbol
      when :xx
        assert_equal("11", a.value)
      when :yy
        assert_equal("22", a.value)
      else
        raise
      end
    end

    a1 = a(:xx, 11)
    assert_equal("a(:xx, 11)", a1.to_ruby)
    assert_equal("a(:xx, 11)", eval(a1.to_ruby).to_ruby)
    a1 = a(:xx, 11, :yy, 22)
    assert_equal("a(:xx, 11, :yy, 22)", a1.to_ruby)
    assert_equal("a(:xx, 11, :yy, 22)", eval(a1.to_ruby).to_ruby)

    a1 = a(:xx, 11, :yy, 22)
    a2 = a(:xx, 11, :yy, 22)
    assert_equal(true, a1 == a1)
    assert_equal(true, a1 == a2)
    assert_equal(a1, a2)
    a2[1] = a(:yy, 33)
    assert_equal(false, a1 == a2)
    assert_equal(true, a1 != a2)
  end

  def test_has_id_element
    e1 = Element.new(:x) { Element.new(:withid, :id=>"aaa") { "text" } }
    assert_equal(true, e1.has_id_element?)
    e2 = Element.new(:x) { Element.new(:y) { "text" } }
    assert_equal(false, e2.has_id_element?)

    p = Element.new(:parent) { [ e1, e2] }
    assert_equal(true, p.has_id_element?)
    p = Element.new(:parent) { [ e2, e2.clone] }
    assert_equal(false, p.has_id_element?)
    
  end

  def test_equal
    e1 = (Element.new("x") << Attr.new(:id, 1234) << Attr.new(:class, 4567))
    e2 = (Element.new("x") << Attr.new(:class, 4567) << Attr.new(:id, 1234) )
    e3 = e1.clone
    assert_equal(e1, e1)
    assert_equal(true, e1 == e1)
    assert_equal(e1, e2)
    assert_equal(true, e1 == e2)
    assert_equal(e1, e3)
    assert_equal(true, e3 == e1)
    assert_equal(e3, e2)
    assert_equal(true, e3 == e2)

    e1[:id] = 9876
    assert_equal(true, e1 != e2)
    assert_equal(false, e1 == e2)
    e2[:id] = 9876
    assert_equal(false, e1 != e2)
    assert_equal(true, e1 == e2)
    assert_equal(e1, e2)

    e1.set_tag(:y)
    assert_equal(true, e1 != e2)
    assert_equal(false, e1 == e2)
    e2.set_tag(:y)
    assert_equal(false, e1 != e2)
    assert_equal(true, e1 == e2)
    assert_equal(e1, e2)

    e1.init_body { "zzzz" }
    assert_equal(false, e1 == e2)
    assert_equal(true, e1 != e2)
    e2.init_body { "zzzz" }
    assert_equal(true, e1 == e2)
    assert_equal(false, e1 != e2)
    assert_equal(e1, e2)
  end

  def test_copy_on_write
    e1 = (Element.new("x") << Attr.new(:id, 1234) << Attr.new(:class, 4567))
    e2 = (Element.new("x") << Attr.new(:class, 4567) << Attr.new(:id, 1234) )
    assert_equal(false, e1.attrs.shared)
    e3 = e1.clone
    e4 = e3.clone
    assert_equal(true, e1.attrs.shared)
    e3[:id] = 9876
    assert_equal(e1, e1)
    assert_equal(true, e1 == e1)
    assert_equal(e1, e2)
    assert_equal(true, e1 == e2)
    assert_equal(true, e1 != e3)
    e1[:id] = 9876
    assert_equal(true, e1 == e3)

    assert_equal(e2, e4)
  end

  def test_children
    assert_equal([], Null.children)
    assert_equal([], Node::to_node("aaa").children)
    assert_equal([], e(:x).children)
    assert_equal([ e(:y) ], e(:x) { e(:y) } .children)
    assert_equal([ TextElement.new("1"), TextElement.new("2"), TextElement.new("3")],
                 Node::to_node([1,2,3]).children)
  end

  def test_element_with_id
    e1 = e(:x, :id=>1)
    e2 = e(:x, :id=>2)
    a = [] ; e1.each_element_with_id { |e| a << e.hid }
    assert_equal([ "1" ], a)
    a = [] ; (e1 + e2 + e1).each_element_with_id { |e| a << e.hid }
    assert_equal([ "1", "2", "1" ], a)
    a = [] ; (e(:x, :id=>1) { e(:y, :id=>2) } ).each_element_with_id { |e| a << e.hid }
    assert_equal([ "1" ], a)
    a = [] ; (e(:x, :id=>1) { e(:y, :id=>2) } ).each_element_with_id(true) { |e| a << e.hid }
    assert_equal([ "1", "2" ], a)

    a = [] ; (e(:x, :id=>1) { e(:y, :id=>2) } * 2 + e1).each_element_with_id(true) { |e| a << e.hid }
    assert_equal([ "1", "2" , "1", "2", "1" ], a)

    a = [] ; (e(:x) { e(:y, :id=>2) } ).each_element_with_id { |e| a << e.hid }
    assert_equal([ "2" ], a)

    e3 = e(:x) { e1 }
    a = [] ; (e3 + e2 + e1).each_element_with_id { |e| a << e.hid }
    assert_equal([ "1", "2", "1" ], a)

    e4 = e(:x) { e3 + e2 + e1 }
    a = [] ; (e4 + e3 + e2 + e1).each_element_with_id { |e| a << e.hid }
    assert_equal([ "1", "2", "1","1", "2", "1" ], a)

  end

  def test_assign
    x = e(:xxx, :id=>"111")
    y = e(:yyy, :id=>"222")
    x[:id] = y[:id] = nil
    assert_equal(e(:xxx), x)
    assert_equal(e(:yyy), y)
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestNode.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestNode.new(method))
    end
  end
end

