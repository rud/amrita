require 'open3'
require 'runit/testcase'
require 'cgi'
require 'amrita/parts'

class TestBBS < RUNIT::TestCase
  def setup
    Dir::mkdir "data" unless File::directory?("data")
    File::open("data/board.txt", "w") do |f|
      f.puts "test\n\n\n"
      f.puts "a\n\na\n"
      f.puts "b\n\nb\n"
      f.puts "test\n\ntest\n"
    end

    Dir::mkdir "data/test" unless File::directory?("data/test")
    File::open("data/test/subject.txt", "w") do |f|
    end
  end

  def teardown
    system "rm -rf data"
  end

  def execbbs(param)
    i, o, e = *(Open3::popen3("ruby -I.. ../bbsmain.cgi"))
    para = param.collect do |k,v|
      "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"
    end.join(" ")
    i.puts  para
    i.close
    emsg = e.read
    STDERR.print emsg if emsg
    assert_equal("Content-Type: text/html", o.readline.chomp("\r\n"))
    o.readline
    ret = Amrita::HtmlParser::parse_io(o)
    puts ret
    ret
  end

  def test_top
    html = execbbs({})
    links = html.find_all { |e| e.tagname == "a" }
    assert_equal('?&template=board&board=a', links[0][:href])
    assert_equal('?&template=board&board=b', links[1][:href])
    assert_equal('?&template=board&board=test', links[2][:href])
    assert_equal('test', links[2].body.to_s)
  end

  def test_board
    html = execbbs(:template=>"board", :board=>"test")
    tables = html.find_all { |e| e.tagname == "table" }
    assert_equal(7, tables.size)
  end

  def test_newthread
    html = execbbs(:action=>"newthread", :board=>"test", :from=>"aaa", :mail=>"mail@amrita",
                   :subject=>"testthread", :message=>"hello\nhello")
    assert_equal('<meta http-equiv="refresh" content="1;URL=?&template=board&board=test">', html.find { |e| e.tagname == "meta" }.to_s)
    File::open("data/test/subject.txt") do |f|
      f.read =~ /(\d*).dat<>(.*)/
      threadid = $1
      assert_equal("testthread", $2)
      File::open("data/test/#{threadid}.dat") do |f|
        a = f.read.chomp.split("<>")
        assert_equal('aaa', a[0])
        assert_equal('mail@amrita', a[1])
        assert_equal('hello<br>hello', a[3])
      end
    end

    html = execbbs(:board=>"test", :from=>"bbb", :mail=>"mail@amrita",
                   :subject=>"testthread2", :message=>"second\nthread")
    assert_equal('<meta http-equiv="refresh" content="1;URL=?&template=board&board=test">', html.find { |e| e.tagname == "meta" }.to_s)
    File::open("data/test/subject.txt") do |f|
      l = f.readlines[0]
      l =~ /(\d*).dat<>(.*)/
      threadid = $1
      assert_equal("testthread2", $2)
      File::open("data/test/#{threadid}.dat") do |f|
        a = f.readline.chomp.split("<>")
        assert_equal('bbb', a[0])
        assert_equal('mail@amrita', a[1])
        assert_equal('second<br>thread', a[3])
      end
    end
  end

  def test_newarticle
    threadid = nil
    html = execbbs(:action=>"newarticle", :board=>"test", :from=>"aaa", :mail=>"mail@amrita",
                   :subject=>"testthread", :message=>"hello\nhello")
    assert_equal('<meta http-equiv="refresh" content="1;URL=?&template=board&board=test">', html.find { |e| e.tagname == "meta" }.to_s)
    File::open("data/test/subject.txt") do |f|
      f.read =~ /(\d*).dat<>(.*)/
      threadid = $1
    end
    html = execbbs(:board=>"test", :from=>"xxx", :mail=>"mail@amrita",
                   :thread=>threadid, :message=>"12345")
    assert_equal('<meta http-equiv="refresh" content="1;URL=?&template=board&board=test">', html.find { |e| e.tagname == "meta" }.to_s)
    File::open("data/test/#{threadid}.dat") do |f|
      a = f.readline.chomp.split("<>")
      assert_equal('aaa', a[0])
      assert_equal('mail@amrita', a[1])
      assert_equal('hello<br>hello', a[3])
      a = f.readline.chomp.split("<>")
      assert_equal('xxx', a[0])
      assert_equal('mail@amrita', a[1])
      assert_equal('12345', a[3])
    end

    html = execbbs(:template=>"board", :board=>"test")
    tables = html.find_all { |e| e.tagname == "table" }
    assert_equal(8, tables.size)

    html = execbbs(:template=>"thread", :board=>"test", :thread=>threadid)
    p html.to_s
    tables = html.find_all { |e| e.tagname == "dt" }
    assert_equal(2, tables.size)
  end
end


#--- main program ----
if __FILE__ == $0
  require 'runit/cui/testrunner'
  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestBBS.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestBBS.new(method))
    end
  end
end

