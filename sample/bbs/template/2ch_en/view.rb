
module BBS2chEn
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
  end
  
  module BBSThread
  end

  module BBSThreadSummary
  end

  module Board
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

    def advertize1
      nil
    end

    def advertize2
      nil
    end

    def advertize3
      nil
    end
  end

  module Article
    def init_view
      unless name
        extend ArticleAnonymous
      else
        if mail
          extend ArticleWithMail
        else
          extend ArticleWithoutMail
        end
      end
    end
  end
end

$amritabbs_config[:view_modules]["2ch_en"] = BBS2chEn

