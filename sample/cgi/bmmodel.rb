#!/usr/bin/ruby

require 'amrita/template'

class Item
  include Amrita::ExpandByMember
  attr_reader :group, :name, :url

  def initialize(group, name, url)
    @group, @name, @url = group, name, url
  end

  def to_s
    %Q[#{@group}|#{@name}|#{@url}]
  end

  def link
    e(:a, :href=>@url) { @url }
  end
end

class BookmarkList
  attr_reader :groups

  def initialize
    @groups = {}
  end

  def load_from_file(path)
    File::open(path) do |f|
      f.each do |line|
        begin
          add_new_item(*line.chomp.split('|'))
        rescue
        end
      end
    end
  end

  def save_to_file(path)
    File::open(path, "w") do |f|
      @groups.each do |k, v|
        v.each do |data|
          f.puts data.to_s
        end
      end
    end
  end

  def add_new_item(group="", name="", url="", *x)
    item = Item.new(group, name, url)
    @groups[group] ||= []
    @groups[group] << item
  end
end

if __FILE__ == $0
  require 'runit/testcase'
  require 'runit/cui/testrunner'

  class TestBMModel < RUNIT::TestCase
    def test_item
      item = Item.new("aa", "bb", "http://www.xxx.com/")
      assert_equal("aa", item.group)
      assert_equal("bb", item.name)
      assert_equal("http://www.xxx.com/", item.url)
    end

    def test_bookmarkmodel
      bm = BookmarkList.new
      assert_equal(0, bm.groups.size())
      assert_equal({}, bm.groups)
      
      bm.add_new_item("g", "nm", "http://www.xxx.com/")
      assert_equal(1, bm.groups.size())
      assert_equal(1, bm.groups["g"].size())
      assert_equal("nm", bm.groups["g"][0].name)
      assert_equal("http://www.xxx.com/", bm.groups["g"][0].url)
    end

    def test_load
      bm = BookmarkList.new
      bm.load_from_file("bookmark.dat.sample")
      assert_equal(3, bm.groups.size())
      
      assert_equal(3, bm.groups["BBS"].size())
      assert_equal("2ch", bm.groups["BBS"][0].name)
      assert_equal("http://www.ruby-lang.org/", bm.groups["Script Languages"][0].url)
    end

    def test_save
      tmp = "/tmp/bmtest#{$$}"
      bm = BookmarkList.new
      bm.load_from_file("bookmark.dat.sample")
      bm.add_new_item("html", "amrita", "http://kari.to/amrita/")
      assert_equal(4, bm.groups.size())
      
      assert_equal(3, bm.groups["BBS"].size())
      assert_equal("2ch", bm.groups["BBS"][0].name)
      assert_equal("http://www.ruby-lang.org/", bm.groups["Script Languages"][0].url)
      assert_equal(1, bm.groups["html"].size())
      assert_equal("amrita", bm.groups["html"][0].name)

      bm.save_to_file(tmp)

      bm = BookmarkList.new
      bm.load_from_file(tmp)
      assert_equal(4, bm.groups.size())
      assert_equal(3, bm.groups["BBS"].size())
      assert_equal("2ch", bm.groups["BBS"][0].name)
      assert_equal("http://www.ruby-lang.org/", bm.groups["Script Languages"][0].url)
      assert_equal(1, bm.groups["html"].size())
      assert_equal("amrita", bm.groups["html"][0].name)
    ensure
      File::unlink tmp
    end
  end

  if ARGV.size == 0
    RUNIT::CUI::TestRunner.run(TestBMModel.suite)
  else
    ARGV.each do |method|
      RUNIT::CUI::TestRunner.run(TestBMModel.new(method))
    end
  end
end

