require 'runit/testcase'
require 'amrita/ams.rb'

class TestAms < RUNIT::TestCase
  include Amrita
  include HtmlCompiler

  def test_ams1
    tempfile = "/tmp/amritatest#{$$}"
    File.open(tempfile, "w") { |f| f.print <<-END }
    <AmritaScript> <!--
      data = { 
        :a => "ams test" 
      } 
    //--></AmritaScript>
    <p id="a">sample_text</p>
    END

    t = AmsTemplate.new(tempfile)  
    result = ""
    t.expand(result)
    assert_equal("    <p>ams test</p>\n", result)
  ensure
    #File.open(tempfile) { |f| puts f.read }
    File::unlink(tempfile)
  end

  def test_ams2
    tempfile = "/tmp/amritatest#{$$}"
    File.open(tempfile, "w") { |f| f.print <<-END }
    <AmritaScript type="module"> <!--
      def a
        "ams test module type" 
      end
    //--></AmritaScript>
    <p id="a">sample_text</p>
    END

    t = AmsTemplate.new(tempfile)  
    result = ""
    t.expand(result)
    assert_equal("    <p>ams test module type</p>\n", result)
  ensure
    #File.open(tempfile) { |f| puts f.read }
    File::unlink(tempfile)
  end

  def test_yaml1
    tempfile = "/tmp/amritatest#{$$}"
    File.open(tempfile, "w") { |f| f.print <<-END }
    <AmritaScript type="yaml"> <!--
      a: "ams test"
    //--></AmritaScript>
    <p id="a">sample_text</p>
    END

    t = AmsTemplate.new(tempfile)  
    result = ""
    t.expand(result)
    assert_equal("    <p>ams test</p>\n", result)
  ensure
    #File.open(tempfile) { |f| puts f.read }
    File::unlink(tempfile)
  end

end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestAms.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestAms.new(method))
    end
  end
end

