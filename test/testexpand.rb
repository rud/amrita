
require 'runit/testcase'
require 'amrita/node_expand'

class TestNodeExpand < RUNIT::TestCase
  include Amrita

  def test_string
    e = e(:x, :id=>"aaa") { "xyz" }
    assert_equal('e(:x) { "abcdefg" }', e.expand1("abcdefg").to_ruby)
    assert_equal('e(:x) { "abcdefg" }', eval(e.expand1("abcdefg").to_ruby).to_ruby)
  end

  def test_nil
    e = e(:x, :id=>"aaa") { "xyz" }

    assert_equal('Amrita::Null', e.expand1(nil).to_ruby)
    assert_equal('Amrita::Null', e.expand1(false).to_ruby)
  end

  def test_array
    e = e(:x, :id=>"aaa") { "xyz" }
    a = [ 1, 2, 3]
    assert_equal('[ e(:x) { "1" }, e(:x) { "2" }, e(:x) { "3" } ]', 
                 e.expand1(a).to_ruby)
    assert_equal('[ e(:x) { "1" }, e(:x) { "2" }, e(:x) { "3" } ]', 
                 Amrita::Node::to_node(eval(e.expand1(a).to_ruby)).to_ruby)

    context = ExpandContext.new
    context.delete_id = false
    context.delete_id_on_copy = false
    assert_equal(Node::to_node([ e(:x,a(:id, "aaa")) { "1" }, e(:x,a(:id, "aaa")) { "2" }, e(:x,a(:id, "aaa")) { "3" } ]),
                 e.expand1(a, context))
  end

  def test_hash
    e = e(:x, :id=>"aaa") { "xyz" }
    d = { :aaa =>"abcd" }
    assert_equal('e(:x) { "abcd" }',
                 e.expand(d).to_ruby)
    context = ExpandContext.new
    context.delete_id = false
    assert_equal(e(:x, :id=>"aaa") { "abcd" },
                 e.expand(d, context))

  end

  def test_hasharray
    e = e(:x, :id=>"aaa") { 
      e(:y, :id=>"zz") { "aa" }
    }
    d = { :aaa => { :zz=>[1,2,3] } }

    assert_equal('e(:x) { [ e(:y) { "1" }, e(:y) { "2" }, e(:y) { "3" } ] }',
                 e.expand(d).to_ruby)
    context = ExpandContext.new
    context.delete_id = false
    context.delete_id_on_copy = false
    assert_equal(e(:x,a(:id, "aaa")) { [ e(:y,a(:id, "zz")) { "1" }, e(:y,a(:id, "zz")) { "2" }, e(:y,a(:id, "zz")) { "3" } ] },
                 e.expand(d,context))
  end

  def test_expandbymember
    e = e(:x, :id=>"aaa") { "xyz" }
    d = Struct.new(:Struct1, :aaa).new
    d.aaa = "struct data"
    d.extend ExpandByMember
    assert_equal('e(:x) { "struct data" }',
                 e.expand(d).to_ruby)
  end

  def test_attrarray
    e = e(:x, :id=>"aaa", :aaa=>"bbb") { "xyz" }
    d = { :aaa=>a(:yyy, 123) }
    assert_equal(e(:x,a(:aaa, "bbb"),a(:yyy, "123")) { "xyz" },
                 e.expand(d))
    assert_equal('e(:x,a(:aaa, "bbb"),a(:yyy, "123")) { "xyz" }',
                 eval(e.expand(d).to_ruby).to_ruby)
  end

  def test_attrarray2
    # This test is from bug report from Brandt Kurowski
    require "amrita/format"
    require "amrita/parser"
    template1 = HtmlParser::parse_text '<p id="foo"></p><p id="bar"></p>'
    template2 = HtmlParser::parse_text '<p id="foo">one</p><p id="bar">two</p>'

    data = {
      :foo => 'day',
      :bar => a(:lang => 'en') { 'night' },
    }
    
    assert_equal('<p>day</p><p lang="en">night</p>', format_inline(data) { template1 })
    assert_equal('<p>day</p><p lang="en">night</p>', format_inline(data) { template2 })
  end

  def test_nodelete
    e = e(:x, :id=>"aaa") { "xyz" }
    d = { :aaa =>"abcd" }
    assert_equal('e(:x) { "abcd" }', e.expand(d).to_ruby)
    context = Amrita::ExpandContext.new
    context.delete_id = false
    assert_equal('e(:x,a(:id, "aaa")) { "abcd" }', e.expand(d, context).to_ruby)

    e = e(:x, :id=>"aaa") { "xyz" }
    a = [ 1, 2, 3]
    assert_equal('[ e(:x) { "1" }, e(:x) { "2" }, e(:x) { "3" } ]', 
                 e.expand1(a, context).to_ruby)
    context.delete_id_on_copy = false
    assert_equal('[ e(:x,a(:id, "aaa")) { "1" }, e(:x,a(:id, "aaa")) { "2" }, e(:x,a(:id, "aaa")) { "3" } ]',
                 e.expand1(a, context).to_ruby)
  end

  def test_attr_expand1
    e = e(:a, :href=>"@url") { e(:span, :id=>"url") }
    d = { :url=>"http://www.ruby-lang.org/" } 
    assert_equal('e(:a,a(:href, "@url")) { e(:span) { "http://www.ruby-lang.org/" } }', e.expand(d).to_ruby)
    context = Amrita::ExpandContext.new
    context.expand_attr = true
    assert_equal('e(:a,a(:href, "http://www.ruby-lang.org/")) { e(:span) { "http://www.ruby-lang.org/" } }', e.expand(d, context).to_ruby)
  end

  def test_attr_expand2
    e = e(:a, :id=>"url") 
    url = "http://www.ruby-lang.org/"
    d = { :url=>a(:href,url) { url } } 
    assert_equal('e(:a,a(:href, "http://www.ruby-lang.org/")) { "http://www.ruby-lang.org/" }', e.expand(d).to_ruby)
  end

  def test_attr_expand3
    require 'amrita/parser'
    require 'amrita/format'
    
    template = HtmlParser.parse_text <<-END
      <body id=body>
        <table id=table>
          <tr id=list><td id=xxx><td id=yyy></tr>
        </table>
      </body>
    END


    data = { 
      :body=>a(:bgcolor=>"blue") {
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
    assert_equal(Node::to_node([ "      ", e(:body,a(:bgcolor, "blue")) { [ "\n        ", e(:table,a(:border, "1")) { [ "\n          ", [ e(:tr) { [ e(:td) { "x1" }, e(:td) { "y1" } ] }, e(:tr) { [ e(:td) { "x2" }, e(:td) { "y2" } ] } ], "\n        " ] }, "\n      " ] }, "\n" ]) ,
        template.expand(data))
    context = DefaultContext.clone
    context.delete_id = false

    assert_equal(Node::to_node([ "      ", e(:body,a(:id, "body"),a(:bgcolor, "blue")) { [ "\n        ", e(:table,a(:id, "table"),a(:border, "1")) { [ "\n          ", [ e(:tr) { [ e(:td) { "x1" }, e(:td) { "y1" } ] }, e(:tr) { [ e(:td) { "x2" }, e(:td) { "y2" } ] } ], "\n        " ] }, "\n      " ] }, "\n" ]),
       template.expand(data, context))
  end

  def test_attr_expand4
    e = e(:x, :aaa=>"@xxx") { "xyz" }
    assert(e.has_expandable_attr?)
    d = { :xxx=>"123" } 
    assert_equal(e(:x, :aaa=>"@xxx") { "xyz" }, e.expand(d))

    context = Amrita::ExpandContext.new
    context.expand_attr = true
    assert_equal(e(:x, :aaa=>123) { "xyz" }, e.expand(d, context))
  end

  def test_hasharray2
    require 'amrita/parser'
    require 'amrita/format'

    template = HtmlParser.parse_text <<-END
      <table><tr id="list"><td id="xxx"></td><td id="yyy"></td></tr></table>
    END
    
    data = {:list=>[{:xxx=>"x1", :yyy=>"y1"}, {:xxx=>"x2", :yyy=>"y2"}]}
    context = Amrita::ExpandContext.new
    assert_equal('<table><tr><td>x1</td><td>y1</td></tr><tr><td>x2</td><td>y2</td></tr></table>'.gsub(/\s/, ''),
                 template.expand(data, context).to_s.gsub(/\s/, ''))
    context.delete_id = false
    context.delete_id_on_copy = false
    assert_equal(' <table><tr id="list"><td id="xxx">x1</td><td id="yyy">y1</td></tr><tr id="list"><td id="xxx">x2</td><td id="yyy">y2</td></tr></table> '.gsub(/\s/, ''),
                 template.expand(data, context).to_s.gsub(/\s/, ''))
  end

  def test_node_expand
    n = Null
    assert_exception(RuntimeError) { n.expand([]) }

    assert_equal(Null, n.expand1(true))
    assert_equal(Null, n.expand1(false))
    assert_equal(Null, n.expand1("abc"))
    assert_equal(Null, n.expand1([1,2,3]))
    assert_equal(Null, n.expand1({ :aaa=> "xyz"}))

    n = TextElement.new("text")
    assert_equal(n, n.expand1(true))
    assert_equal(Null, n.expand1(false))
    assert_equal(TextElement.new("abc"), n.expand1("abc"))
    a = Node::to_node([1,2,3])
    assert_equal(a, n.expand1([1,2,3]))
    assert_equal(n, n.expand1({ :aaa=> "xyz"}))

    n = SpecialElement.new("!--", "comment")
    assert_equal(n, n.expand1(true))
    assert_equal(Null, n.expand1(false))
    assert_equal(TextElement.new("abc"), n.expand1("abc"))
    a = Node::to_node([1,2,3])
    assert_equal(a, n.expand1([1,2,3]))
    assert_equal(n, n.expand1({ :aaa=> "xyz"}))

    n = Node::to_node([ "text", nil, e(:x)])
    ans = Node::to_node([ "text", nil, e(:x)])
    assert_equal(ans, n.expand1(true))
    assert_equal(Null, n.expand1(false))
    assert_equal(TextElement.new("abc"), n.expand1("abc"))
    a = Node::to_node([1,2,3])
    assert_equal(a, n.expand1([1,2,3]))
    assert_equal(ans.type, n.expand1({ :aaa=> "xyz"}).type)
    assert_equal(ans, n.expand1({ :aaa=> "xyz"}))
  end

  def test_string2
    DefaultContext.expand_attr = true
    e = e(:x, :id=>"xxx") { e(:y, :yyy=>"@zzz") { "xyz" } }
    data = { :xxx => { :zzz => "123" } }
    assert_equal(e(:x) { e(:y,a(:yyy, "123")) { "xyz" } }, e.expand(data))

    e = e(:x, :id=>"xxx", :yyy=>"@zzz") { "xyz" }
    data = { :xxx =>"123", :zzz => "456" } 
    assert_equal(e(:x,a(:yyy, "456")) { "123" } , e.expand(data))
  ensure
    DefaultContext.expand_attr = false
  end

  def test_delete_id
    e = e(:body) { e(:x, :id=>'aaa', :abc=>'efg') { e(:y, :id=>'zzz') { 'text' } } }
    d = {
      :aaa=> a(:yyy=>"zzz") {
        { :zzz=>"aaa" }
      }
    }
    context = DefaultContext.clone
    context.delete_id = false
    assert_equal(e(:body) { e(:x,a(:abc, "efg"),a(:id, "aaa"),a(:yyy, "zzz")) { e(:y,a(:id, "zzz")) { "aaa" } } },
                 e.expand(d, context))
    context.delete_id = true
    assert_equal(e(:body) { e(:x,a(:abc, "efg"),a(:yyy, "zzz")) { e(:y) { "aaa" } } },
                 e.expand(d, context))
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestNodeExpand.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestNodeExpand.new(method))
    end
  end
end

