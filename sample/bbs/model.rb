
require 'view'

module BBS
  class ModelObject
    include Amrita
    attr_reader :bbs

    def initialize(bbs)
      if ModelObject.ancestors.include?(ExpandByMember)
        p type.ancestors
        p ModelObject.ancestors
      end
      @bbs = bbs
      bbs.install_view_module(self)
    end

    def loc
      bbs.loc
    end

    def theme_selecter
      $amritabbs_config[:themes].collect do |t|
        { 
          :theme => if t == bbs.loc.theme or (bbs.loc.theme == nil and t == $amritabbs_config[:default_theme])
                      "*#{t}*"
                    else
                      a(:href=>bbs.loc.theme_change(t)) { t } 
                    end
        }
      end
    end
  end

  class ThemeSelecter < ModelObject
    def initialize
    end
  end

  class BoardList < ModelObject
    include CommonView::BoardList
    attr_reader :categories, :last_update

    def initialize(bbs)
      super
      @categories = []
      path = bbs.data_path(nil, "board.txt")
      load_from_file(path)
    end

    def get_board(key)
      @categories.each do |c|
        c.boards.each do |b|
          return b if b.key == key
        end
      end
      nil
    end

    def load_from_file(path)
      @current_category = nil
      a = []
      File::open(path) do |f|
        f.each do |l|
          l.chomp!
          if l.size > 0
            a << l
          else
            a << nil
          end
          if a.size == 3
            add_item(*a)
            a = []
          end
        end
      end

      @last_update = File::stat(path).mtime
    end

    def add_item(name, url, key)
      if url or key
        @current_category.add_boad(Board.new(bbs, name, url, key))
      else
        @current_category = Category.new(bbs, name)
        @categories << @current_category
      end
    end
  end

  class Category < ModelObject
    include CommonView::Category
    attr_reader :category, :boards

    def initialize(bbs, name)
      super(bbs)
      @category = name
      @boards = []
    end

    def add_boad(b)
      @boards << b
    end
  end

  class Board < ModelObject
    include ExpandByMember
    include CommonView::Board
    attr_reader :name, :url, :key

    def initialize(bbs, name, url, key)
      super(bbs)
      @name, @url, @key = name, url, key
    end

    def link
      if @url 
        a(:href=>@url) { @name }
      else
        url = loc.to_board(@key).to_s
        a(:href=>url) { @name }
      end
    end

    def each_thread(&block)
      path = bbs.data_path(@key, "subject.txt")
      n = 1
      File::open(path) do |f|
        ff = f.each do |l|
          fname, title = *l.split("<>")
          next unless File::readable?(bbs.data_path(@key, fname))
          yield(n, fname, title)
          n = n + 1
        end
      end
    end

    def get_thread(threadid)
      fn = threadid + ".dat"
      each_thread do |n, fname, title|
        return BBSThread.new(bbs, self, n, fname, title) if fn == fname
      end
      nil
    end
  end

  class BBSThreadTitle < ModelObject
    include CommonView::BBSThreadTitle
    attr_reader :title, :num, :has_summary, :threadid
    def initialize(bbs, board, num, has_summary, fname, title)
      super(bbs)
      @board, @fname, @title, @num, @has_summary = 
        board, fname, title, num, has_summary
      @threadid = @fname.gsub(".dat","")
    end
  end

  class BBSThread < ModelObject
    include ExpandByMember
    include CommonView::BBSThread
    attr_reader :title, :board, :num, :articles, :threadid

    def initialize(bbs, board, num, fname, title)
      super(bbs)
      @board, @fname, @title, @num = 
        board, fname, title, num
      @threadid = @fname.gsub(".dat","")
      load_data_file
    end

    def load_data_file
      path = bbs.data_path(board.key, "subject.txt")
      File::open(path) do |f|
        f.each do |l|
          if l =~ /#{@threadid}.dat<>(.*)$/
            @title= $1
            break
          end
        end
      end

      path = bbs.data_path(board.key, @fname)
      #IO::popen("nkf -e #{path}") do |f|
      File::open(path) do |f|
        num = 0
        @articles = f.collect do |l|
          num = num + 1
          a = l.chomp.split("<>").collect { |x| x == "" ? nil : x }
          Article.new(bbs, num, *a[0..3])
        end
        @articles_num = num
        @articles = loc.select(@articles)
      end
    end

  end

  class Article < ModelObject
    include CommonView::Article
      attr_reader :num, :name, :mail, :date, :text

    def initialize(bbs, num, name=nil, mail=nil, date=nil, text=nil)
      super(bbs)
      @num, @name, @mail, @date =
        num, name, mail, date
      @text = SanitizedString.new(text) if text
      init_view
    end
  end
end
