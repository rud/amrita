require 'runit/testcase'
require 'amrita/parser'
require 'amrita/format'

$cmds = [
  "ruby amrita.rb 1 ",
  "ruby amrita.rb 1 preformat",
  "ruby amrita.rb 1 compiler",
  "ruby amrita.rb 1 usehint",
  "ruby plain.rb 1",
  " eruby eruby.rhtml 1",
]


class TestBenchMark < RUNIT::TestCase
  include Amrita

  def parse_html(cmd)
    IO::popen(cmd) do |p|
      ret = HtmlParser::parse_io(p).to_s.gsub(" ", "")
      #p ret
      ret
    end
  end

  def test_all
    ENV["CNT"] = "1"
    assert_equal(parse_html($cmds[0]), parse_html($cmds[5]))
    assert_equal(parse_html($cmds[0]), parse_html($cmds[1]))
    assert_equal(parse_html($cmds[0]), parse_html($cmds[2]))
    assert_equal(parse_html($cmds[0]), parse_html($cmds[3]))
    assert_equal(parse_html($cmds[0]), parse_html($cmds[4]))
  end

end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestBenchMark.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestBenchMark.new(method))
    end
  end
end

