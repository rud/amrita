# test of Path

$: << "../lib"

require 'runit/testcase'
require 'amrita/parser'
require 'amrita/node_expand'
require 'amrita/compiler'

$SHOW_SRC  = false
$SHOW_RESULT = false
$DEBUG_COMPILER = true

class TestHtmlCompiler < RUNIT::TestCase
  include Amrita
  include HtmlCompiler
  FormatterClass = AsIsFormatter
  #FormatterClass = SingleLineFormatter  # this works
  #FormatterClass = PrettyPrintFormatter # this does not work now

  def check_compiler_all(html, data, hint=nil)
    [AsIsFormatter, SingleLineFormatter].each do |f|
      template = HtmlParser.parse_text(html)
      pre_formatted_template = template.pre_format(f.new).result_as_top
      [ template, pre_formatted_template].each do |tmpl|
        context = DefaultContext.clone
        check_compiler(tmpl, data, hint, f, context)
        context.delete_id = false
        context.delete_id_on_copy = false
        check_compiler(tmpl, data, hint, f, context)
        context.delete_id = true
        context.expand_attr = true
        check_compiler(tmpl, data, hint, f, context)
        context.delete_id = false
        context.delete_id_on_copy = false
        check_compiler(tmpl, data, hint, f, context)
      end
    end
  end

  def check_compiler(template, data, hint=nil, 
                     formatter_cls=AsIsFormatter, 
                     context = DefaultContext.clone, 
                     show_src=$SHOW_SRC)

    template = HtmlParser.parse_text(template) unless template.kind_of?(Node)
    formatter = formatter_cls.new
    formatter.set_attr_filter(:__id => :id)

    c = Compiler.new(formatter)
    #c.use_const_def = false
    c.delete_id = context.delete_id
    c.expand_attr = context.expand_attr
    c.debug_compiler = $DEBUG_COMPILER
    c.compile(template, hint)

    if show_src
      puts ""
      puts "delete_id=#{c.delete_id} expand_attr=#{c.expand_attr}"
      puts "--------------(source)------------------------"
      puts c.get_result.join("\n")
      puts "\n--------------(source end)--------------------"
    end

    m = Module.new
    m.module_eval c.get_result.join("\n")
    result = ""

    formatter.with_stream(result) {
      m::expand(formatter, data, context)
    }

    if $SHOW_RESULT
      puts "\n--------------(result)------------------------"
      puts result
    end

    # check answer
    #p template
    #p data
    ans = formatter.format(template.expand(data, context), "")
    #p ans
    assert_equals(ans, result)
  rescue RuntimeError, NameError, ScriptError,RUNIT::AssertionFailedError
    puts ""
    puts "delete_id=#{c.delete_id} expand_attr=#{c.expand_attr}"
    p template
    p context
    p data
    p ans
    p template.expand(data)
    p template.expand(data, context)

    puts "--------------(source)------------------------"
    puts c.get_result.join("\n")
    puts "\n--------------(source end)--------------------"
    puts "\n--------------(result)------------------------"
    puts result
    raise
  end

  def test_simple_nohint
    check_compiler_all("<body><x id=aaa></x></body>",
                   { :aaa=>"xxx" },
                   nil
                   )
    check_compiler_all("<body><x id=aaa></x></body>",
                   { :aaa=>"xxx" },
                   AnyData.new
                   )
  end

  def test_simple_nohint2
    check_compiler_all("<body><x>aaaa</x><x id=aaa></x><y><z>zzz text</z></y></body>",
                       { :aaa=>"xxx" },
                       nil
                       )
    check_compiler_all("<body><x>aaaa</x><x id=aaa></x><y><z>zzz text</z></y></body>",
                       { :aaa=>"xxx" },
                       AnyData.new
                       )
  end

  def test_simple
    check_compiler_all("<body><span id=aaa></span></body>",
                   { :aaa=>"xxx" },
                   HashData[ :aaa=>ScalarData ]
                   )
    check_compiler_all("<body><span id=aaa></span></body>",
                       { :aaa=>"xxx" },
                       AnyData.new
                       )
  end

  def test_array
    check_compiler_all("\n<ul>\n<li id=list></li>\n</ul>\n",
                   { :list=>%w(aa bb cc) },
                   HashData[ :list=>AnyData ]
                   )
    check_compiler_all("\n<ul>\n<li id=list></li>\n</ul>\n",
                   { :list=>%w(aa bb cc) },
                   HashData[ :list=>ArrayData[ScalarData] ]
                   )
    check_compiler_all("\n<ul>\n<li id=list></li>\n</ul>\n",
                       { :list=>%w(aa bb cc) },
                       AnyData.new
                       )
  end

  def test_array_of_hash
    check_compiler_all("<table><tr id=list><td id=a><td id=b></table>",
                   { 
                     :list=>[
                       { :a=>1, :b=>2}, 
                       { :a=>10, :b=>20}, 
                       { :a=>100, :b=>200}, 
                     ] 
                   },
                   HashData[ :list=>ArrayData[HashData[ :a=>ScalarData, :b=>ScalarData]]]
                   )
    check_compiler_all("<table><tr id=list><td id=a><td id=b></table>",
                   { 
                     :list=>[
                       { :a=>1, :b=>2}, 
                       { :a=>10, :b=>20}, 
                       { :a=>100, :b=>200}, 
                     ] 
                   },
                   AnyData.new    
                   )
  end


  def test_attr
    check_compiler_all('<a href="@url"><span id=title></span></a>',
                   { :url=>"http://xxxx/", :title=>"yyyy", :color=>"blue" },
                   HashData[ :url=>ScalarData, :title=>ScalarData, :color=>ScalarData]
                   )
    check_compiler_all('<a href="@url"><span id=title></span></a>',
                       { :url=>"http://xxxx/", :title=>"yyyy", :color=>"blue" },
                       AnyData.new
                       )
  end

  def test_attr2
    DefaultContext.expand_attr = true
    data = {
      :table1=>[ 
        { 
          :name=>"Ruby", 
          :author=>"matz" , 
          :url=>"http://www.ruby-lang.org/",
          :title=>"Ruby Home Page" 
        },
        { 
          :name=>"perl", 
          :author=>"Larry Wall" ,
          :url=>"http://www.perl.com/",
          :title=>"Perl.com"
        },
        { 
          :name=>"python", 
          :author=>"Guido van Rossum" ,
          :url=>"http://www.python.org/",
          :title=>"Python Language Website"
        },
      ] 
    }
                   tmpl= <<END
<table border="1">
  <tr><th>name</th><th>author</th><th>webpage</tr>
  <tr id=table1>
    <td id="name"></td>
    <td id="author"></td>
    <td><a id="title" href="@url"></a></td>
  </tr>
</table>
END
    check_compiler(tmpl, data, data.amrita_generate_hint)
    check_compiler(tmpl, data, AnyData.new)
  ensure
    DefaultContext.expand_attr = false
  end

  def test_hash
    d = { :xxx=>111, :yyy=>222 }


    check_compiler_all('<span id=xxx></span><span id=yyy></span>',
                   d,
                   HashData[ :xxx=>AnyData, :yyy=>AnyData ]
                   )
    check_compiler_all('<span id=xxx></span><span id=yyy></span>',
                   d,
                   HashData[ :xxx=>ScalarData, :yyy=>ScalarData ]
                   )
    check_compiler_all('<span id=xxx></span><span id=yyy></span>',
                       d,
                       AnyData.new
                       )
  end

  def test_hash2
    d = { :xxx=>111, :yyy=>{ :zzz=>222 } }
    check_compiler_all('<span id=xxx></span><span id=yyy><span id=zzz></span></span>',
                       d,
                       HashData[ :xxx=>ScalarData, :yyy=>HashData[ :zzz=>ScalarData ]]
                       )
    check_compiler_all('<span id=xxx></span><span id=yyy><span id=zzz></span></span>',
                       d,
                       AnyData.new
                       )
  end

  def test_hash3
    d = { :aaa=>{ :xxx=>111, :yyy=>222} , :bbb=>{ :zzz=>222 } }
    check_compiler('<div id=aaa><span id=xxx></span><span class=cls id=yyy></span></div><div id=bbb><span id=zzz></span></div>',
                       d,
                       HashData[ :aaa=>HashData[:xxx=>ScalarData, :yyy=>ScalarData], :bbb=>HashData[ :zzz=>ScalarData ]]
                       )
    check_compiler('<div id=aaa><span id=xxx></span><span class=cls id=yyy></span></div><div id=bbb><span id=zzz></span></div>',
                       d,
                       AnyData.new
                       )
  end

  def test_member
    klass = Struct.new(nil, :xxx, :yyy)
    s = klass.new("111", "222")
    s.extend Amrita::ExpandByMember
    check_compiler_all('<span id=xxx></span><span id=yyy></span>',
                   s,
                   MemberData[ :xxx=>ScalarData, :yyy=>ScalarData ]
                   )
    check_compiler_all('<span id=xxx></span><span id=yyy></span>',
                       s,
                       AnyData.new
                       )
  end

  def test_member2
    klass = Struct.new(nil, :xxx, :yyy)
    s = klass.new("111", {:zzz=>"222"})
    s.extend Amrita::ExpandByMember
    check_compiler('<span id=xxx></span><span id=yyy><span id=zzz></span></span>',
                   s,
                   MemberData[ :xxx=>ScalarData, :yyy=>HashData[:zzz=>ScalarData] ]
                   )
  end

  def test_proc
    p = proc do |e, context| 
      e[:yyy] = "zzz"
      e.set_text("text set by proc")
      e
    end
    check_compiler_all("<body><x id=aaa abc='efg'>text</x></body>",
                       { :aaa=>p},
                       HashData[ :aaa=>ProcData ]
                       )
    check_compiler_all("<body><x id=aaa abc='efg'>text</x></body>",
                       { :aaa=>p},
                       AnyData.new
                       )
  end

  def test_attrarray1
    d = a(:yyy=>"zzz")
    check_compiler_all("<body><x id=aaa abc='efg'>text</x></body>",
                       { :aaa=>d},
                       HashData[ :aaa=>AttrData ]
                       )
    check_compiler_all("<body><x id=aaa abc='efg'>text</x></body>",
                       { :aaa=>d},
                       AnyData.new
                       )
  end
  def test_attrarray2
    d = {
      :aaa=> a(:yyy=>"zzz") {
        { :zzz=>"aaa" }
      }
    }
    check_compiler("<body><x id=aaa abc='efg'><y id=zzz>text</y></x></body>",
                   d,
                   HashData[ :aaa=>AttrData[HashData[ :zzz=>ScalarData ]]]
                   )
    check_compiler("<body><x id=aaa abc='efg'><y id=zzz>text</y></x></body>",
                   d,
                   AnyData.new
                   )
  end

  def test_attrarray3
    template = <<-END

      <body id=body>
        <table id=table>
          <tr id=list><td id=xxx><td id=yyy></tr>
        </table>
      </body>
    END


    data = { 
      :body=>a(:bgcolor=>"blue", :text=>"red") {
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

    hint = HashData[
      :body=>AttrData[
         HashData[
           :table=>AttrData[
             HashData[
               :list=>ArrayData[
                 HashData[:xxx=>ScalarData, :yyy=>ScalarData]
               ]
             ]
           ]
         ]
      ]
    ]

    check_compiler(template, data, hint)
    check_compiler(template, data, AnyData.new)
  end

  def test_attrarray4
    template = HtmlParser::parse_text <<-END
<table border="1">
  <tr><th>name</th><th>author</th><th>webpage</tr>
  <tr id=table1>
    <td id="name"></td>
    <td id="author"></td>
    <td><a id="webpage"></a></td>
  </tr>
</table>
    END

    data = {

   :table1=>[ 
    { 
      :name=>"Ruby", 
      :author=>"matz" , 
      :webpage=> a(:href=>"http://www.ruby-lang.org/") { "Ruby Home Page" },
    },
    { 
      :name=>"perl", 
      :author=>"Larry Wall" ,
      :webpage=> a(:href=>"http://www.perl.com/") { "Perl.com" },
    },
    { 
      :name=>"python", 
      :author=>"Guido van Rossum" ,
      :webpage=> a(:href=>"http://www.python.org/") { "Python Language Website" },
    },
   ] 
}

    check_compiler(template,
                   data,
                   AnyData.new
                   )
    check_compiler(template,
                   data,
                   nil
                   )
    check_compiler(template,
                   data,
                   data.amrita_generate_hint
                   )
  end

  def test_anydata1
    check_compiler("<body><x id=aaa></x></body>",
                   { :aaa=>"xxx" },
                   AnyData.new
                   )

    check_compiler("<body><x id=aaa></x></body>",
                   { :aaa=>e(:y) { "xxx" } },
                   AnyData.new
                   )

    check_compiler("<table><tr id=list><td id=a><td id=b></table>",
                   { 
                     :list=>[
                       { :a=>1, :b=>2}, 
                       { :a=>10, :b=>20}, 
                       { :a=>100, :b=>200}, 
                       { :a=>1000, :b=>2000}, 
                     ] 
                   },
                   AnyData.new
                   )
  end

  def test_anydata2
    html = <<-END
            <h1 id=title></h1>
            <ul>
               <li id=list></li>
            </ul>
    END

    data = { 
      :title => "title1",
      :list => [e(:x) { 1 }, 2, 3]
    }

    #p html
    #check_compiler(html, data, data.amrita_generate_hint)
    check_compiler(html, data, AnyData.new)
  end

  def test_anydata3
    DefaultContext.expand_attr = true
    begin
      check_compiler('<body><x attr="@attr"></x></body>',
                     { :attr=>"xxx" },
                     AnyData.new
                     )

      check_compiler('<x id="body" attr="@attr" x="yyy">ankimo</x>',
                     { :attr=>"attr", :body => "body" },
                     AnyData.new
                     )

      check_compiler('<silver id="birch"><spilit attr="@attr"></spilit></silver>',
                     { :birch => {:attr => "value"} },
                     AnyData.new
                     )
      check_compiler('<white id="eagle"><silver id="birch">test</silver></white>',
                     {:eagle => true},
                     AnyData.new
                     )
      check_compiler('<x __id="@attr"></x>',
                     {:attr => "escaped_id"},
                     AnyData.new)
    ensure
      DefaultContext.expand_attr = false
    end
  end

  def test_anydata4

    check_compiler(<<-END,
    <div id="index">
      <ul>
         <li id="sec_index">
            <span id="sec_index_title"></span>
            <ul>
               <li id="subsec_index"></li>
            </ul>
         </li>
      </ul>
    </div>
END
                   { 
                     :index => {
                       :sec_index => [
                         { :sec_index_title => "title1",
                           :subsec_index => [11, 12, 13]
                         },
                         { :sec_index_title => "title2",
                           :subsec_index => [21, 22, 23]
                         },
                       ]
                     }
                   },
                   AnyData.new
                   )
  end

  def test_anydata5
    data = Object.new
    data.extend ExpandByMember
    def data.attr
      "xxx"
    end

    def data.body
      self
    end

    DefaultContext.expand_attr = true
    begin
      check_compiler('<body><x attr="@attr"></x></body>',
                     data,
                     AnyData.new
                     )

      check_compiler('<x id="body" attr="@attr">ankimo</x>',
                     data,
                     AnyData.new
                     )

      
      check_compiler('<input type="hidden" name="p" value="@attr">',
                     data,
                     AnyData.new
                     )
    ensure
      DefaultContext.expand_attr = false
    end
  end


  def test_sanitize
    check_compiler("<body><x id=aaa></x></body>",
                   { :aaa=>"<" },
                   HashData[ :aaa=>ScalarData ])
  end

  def test_const_def
    out = ""
    c = Compiler.new(out, "out", "context")
    c.init_src(nil)
    varname = c.new_constant(1, "X")
    assert_equals('C_X0000', varname)
    varname = c.new_constant('2 * 2', "Y")
    assert_equals('C_Y0001', varname)
    assert_equals(["C_X0000 = 1", "C_Y0001 = 2 * 2"], c.const_def_src)

    varname = c.new_constant('e(:a, :href=>"http://www.ruby-lang.org/") { "ruby" }')
    assert_equals('C_0002', varname)

    m = Module.new
    m.module_eval 'extend Amrita'
    m.module_eval c.const_def_src.join("\n")
    assert_equals(1, m::C_X0000)
    assert_equals(4, m::C_Y0001)
    assert_equals('<a href="http://www.ruby-lang.org/">ruby</a>', m::C_0002.to_s)

  end

  def test_dictinaryhint
    check_compiler("<body><x id=aaa></x></body>",
                   { :aaa=>"xxx" },
                   DictionaryHint.new( :aaa => ScalarData )
                   )
    x = Object.new
    x.extend Amrita::ExpandByMember
    def x.aaa
      "xxx"
    end
    check_compiler("<body><x id=aaa></x></body>",
                   x, 
                   DictionaryHint.new( :aaa => ScalarData )
                   )
  end

  def test_generate_hint_from_template
    template = HtmlParser.parse_text  "<body><x id=aaa></x></body>"
    h = template.generate_hint_from_template
    assert_equals(DictionaryHint, h.type)
    assert_equals(AnyData, h.hash[:aaa].type)

    check_compiler("<body><x id=aaa></x></body>",
                   { :aaa=>"xxx" },
                   h
                   )

    template = HtmlParser.parse_text'<span id=xxx></span><span id=yyy></span>'
    h = template.generate_hint_from_template
    assert_equals(DictionaryHint, h.type)
    assert_equals(AnyData, h.hash[:xxx].type)
    assert_equals(AnyData, h.hash[:yyy].type)

    check_compiler_all('<span id=xxx></span><span id=yyy></span>',
                   { :xxx=>"xx", :yyy=>"yy" },
                   h
                   )
  end


end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestHtmlCompiler.suite)
  else
    $SHOW_SRC  = true
    $SHOW_RESULT = true
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestHtmlCompiler.new(method))
    end
  end
end

