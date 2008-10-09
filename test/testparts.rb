require 'runit/testcase'
require 'amrita/parts'

class TestParts < RUNIT::TestCase
  include Amrita

  class EMText
    attr_reader :text
    def initialize(text)
      @text = text
    end
  end

  def test_parts1
    parts_template = TemplateText.new <<-END
    <span class=EMText><em id=text>aaaaa</em></span>
    END

    parts_template.install_parts_to(TestParts)
    t = TemplateText.new '<p id=aaa></p>'
    result = ""
    t.use_compiler = false
    t.expand(result, { :aaa=>EMText.new("xxx") })
    assert_equal("<p><em>xxx</em></p>", result)

    t = TemplateText.new '<p id=aaa></p>'
    result = ""
    #t.debug_compiler = true            
    t.use_compiler = true
    t.expand(result, { :aaa=>EMText.new("xxx") })
    #puts t.src
    assert_equal("<p><em>xxx</em></p>", result)
  end

  class Lang
    attr_reader :lang, :author
    def initialize(lang, author)
      @lang, @author = lang, author
    end
  end

  def test_parts2
    parts_template = TemplateText.new <<-END
    <span class=Lang>
      <dt id=lang>
      <dd id=author>
    </span>
    END

    parts_template.install_parts_to(TestParts)

    data = {
      :list => [
         Lang.new("Ruby", "matz"),
         Lang.new("Perl", "Larry Wall")
      ]
    }

    t = TemplateText.new '<dl><span id=list></span></dl>'
    result = ""
    t.use_compiler = false
    t.expand(result, data)
    assert_equal('<dl>
      <dt>Ruby</dt><dd>matz</dd>
      <dt>Perl</dt><dd>Larry Wall</dd></dl>', result)
    t = TemplateText.new '<dl><span id=list></span></dl>'

    result = ""
    t.use_compiler = true
    t.expand(result, data)
    assert_equal('<dl>
      <dt>Ruby</dt><dd>matz</dd>
      <dt>Perl</dt><dd>Larry Wall</dd></dl>', result)


  end    

  class Lang2
    attr_reader :lang, :author
    def initialize(lang, author)
      @lang, @author = lang, author
    end
  end

  def test_parts3
    template = TemplateText.new <<-END
    <dl>
      <span id=list class=Lang2>
        <dt id=lang>
        <dd id=author>
      </span>
    </dl>
    END

    data = {
      :list => [
         Lang2.new("Ruby", "matz"),
         Lang2.new("Perl", "Larry Wall")
      ]
    }

    template.install_parts_to(TestParts)
    result = ""
    template.use_compiler = true
    template.expand(result, data)
    assert_equal('    <dl>
      
        <dt>Ruby</dt><dd>matz</dd>
        <dt>Perl</dt><dd>Larry Wall</dd>
    </dl>
', result)

    result = ""
    template.use_compiler = false
    template.expand(result, data)
    assert_equal('    <dl>
      
        <dt>Ruby</dt><dd>matz</dd>
        <dt>Perl</dt><dd>Larry Wall</dd>
    </dl>
', result)
  end    

  class EMText2
    attr_reader :text
    def initialize(text)
      @text = text
    end
  end


  def test_parts_withcache
    cachedir = "/tmp/amrit_partstest#{$$}"
    Dir::mkdir(cachedir)
    TemplateFileWithCache::set_cache_dir(cachedir)
    path = File::join(cachedir, "pt1.html")
    
    File::open(path, "w") do |f|
      f.write <<-END
      <span class=EMText2><em id=text>aaaaa</em></span>
      END
    end
    parts_template = TemplateFileWithCache.new(path)  
    parts_template.install_parts_to(TestParts)
    t = TemplateText.new '<p id=aaa></p>'
    result = ""
    t.use_compiler = false
    t.expand(result, { :aaa=>EMText2.new("xxx") })
    assert_equal("<p><em>xxx</em></p>", result)

    t = TemplateText.new '<p id=aaa></p>'
    result = ""
    t.debug_compiler = true            
    t.use_compiler = true
    t.expand(result, { :aaa=>EMText.new("xxx") })
    assert_equal("<p><em>xxx</em></p>", result)
  ensure
    #system "ls -l #{cachedir}"
    #system "cat #{cachedir}/*"
    system "rm -r #{cachedir}"        
  end

  module Elements
  end

  class PartsData
    include Amrita::ExpandByMember
    def header
      extend Elements.const_get('Header')
      self
    end
    def title
      'test title'
    end
  end

  def test_dynamic_extend
    parts_template = TemplateText.new <<END
<span class=Header>
  <h1 id=title></h1>  
</span>
END

    parts_template.install_parts_to(Elements)
    document_template = TemplateText.new <<END
<span id=header></span>
END
    data = PartsData.new
    result = ""
    document_template.expand(result, data)
    assert_equal("\n  <h1>test title</h1>  \n\n", result)

    document_template = TemplateText.new <<END
<span id=header></span>
END
    document_template.use_compiler = true # XXX 
    result = ""
    document_template.debug_compiler = true
    #document_template.set_hint_by_sample_data({ :test=> data })
    document_template.expand(result, data)
    # puts document_template.src
    assert_equal("\n  <h1>test title</h1>  \n\n", result)
  end

end

#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestParts.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestParts.new(method))
    end
  end
end

