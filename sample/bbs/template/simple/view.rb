
module BBSSimple
  module BBSModel
    def board
      current_board
    end

    def thread
      current_thread
    end
  end

  module Category
    include ExpandByMember
  end

  module BoardList
    include ExpandByMember
  end

  module BBSThreadTitle
    include ExpandByMember
    def link
      a(:href=>loc.to_thread(threadid).get_last(50)) { "#{num}: #{title}" } 
    end
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
  end

  module BBSThread
  end

  module Article
    include ExpandByMember

    def init_view
    end
  end
end

$amritabbs_config[:view_modules]["simple"] = BBSSimple

