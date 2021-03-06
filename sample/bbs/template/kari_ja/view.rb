
module BBSKariJa
  module BBSModel
    def board
      current_board
    end

    def thread
      current_thread
    end
  end

  module BoardList
  end
  

  module Category
    include ExpandByMember
  end

  module BBSThreadTitle
  end

  module Board
    def categories
      bbs.boardlist.categories
    end

    def to_board
      a(:href=>loc.to_board(key)) { name }
    end

    def threadtitles
      ret = []
      each_thread do |n, fname, title|
        break if n > $amritabbs_config[:max_thread_title]
        has_summary = ( n < $amritabbs_config[:max_thread_summary])
        ret << BBS::BBSThreadTitle.new(bbs, self, n, has_summary, fname, title)
      end
      ret
    end

    def threadsummary
      ret = []
      each_thread do |n, fname, title|
        break if n > $amritabbs_config[:max_thread_summary]
        ret << BBS::BBSThread.new(bbs, self, n, fname, title)
      end
      ret
    end
  end

  module BBSThread
    def categories
      bbs.boardlist.categories
    end

    def to_board
      a(:href=>loc.to_board(key)) { name }
    end
  end

  module Article
    def init_view
      if num == 1
        extend Article1
      else
        extend ArticleN
      end
    end

    def name
      if mail and super
        e(:a, :href=>"mailto:#{mail}") { super }
      else
        super or true
      end
    end
  end
end

$amritabbs_config[:view_modules]["kari_ja"] = BBSKariJa

