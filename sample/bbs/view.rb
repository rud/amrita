require 'amrita/template'

module CommonView

  module BoardList
    include Amrita::ExpandByMember
  end

  module Category
    include Amrita::ExpandByMember
  end

  module Board
    def header_title
      name
    end

    def title
      name
    end

    def message
      path = bbs.data_path(key, "message.html")
      if File::readable?(path)
        noescape { File::open(path).read }
      else
        nil
      end
    end

    def advertize1
      bbs.advertize_random
    end

    def advertize2
      bbs.advertize_random
    end

    def advertize3
      bbs.advertize_random
    end

    def to_top
      a(:href=>loc.to_top)
    end

    def newthread_form
      a(:action =>$amritabbs_config[:script_name]) do
        {
          :theme=>a(:value=>loc.theme),
          :board=>a(:value=>@key) 
        }
      end
    end
  end

  module BBSThreadTitle
    def link1
      if has_summary
        a(:href=>loc.to_thread(threadid).get_last(50)) { "#{num}:" } 
      else
        a(:href=>loc.to_thread(threadid).get_last(50)) { "#{num}: #{title}" } 
      end
    end

    def link2
      if has_summary
        a(:href=>"##{num}") { title } 
      end
    end
  end

  module BBSThread
    def label
      a(:name=>num) 
    end

    def to_prev
      prev = num - 1
      prev = $amritabbs_config[:max_thread_summary] if prev == 0
      a(:href=>"##{prev}")
    end

    def to_next
      next_ = num + 1
      next_ = 1 if next_ == $amritabbs_config[:max_thread_summary]
      a(:href=>"##{next_}")
    end

    def num_of_article
      articles.size
    end

    def article1
      articles[0]
    end

    def summary_articles
      if articles.size > 10
        [articles[0]] + articles[-10..-1]
      else
        articles
      end
    end

    def navi_all
      a(:href=>loc.to_thread(threadid).get_all)
    end

    def navi_l50
      a(:href=>loc.to_thread(threadid).get_last(50))
    end

    def navi_100
      a(:href=>loc.to_thread(threadid).get_range(1,100))
    end

    def navi_reload
      a(:href=>loc)
    end

    def navi_by100
      (0..(@articles_num/100)).collect do |n|
        a(:href=>loc.get_range(n*100+1, n*100+100)) { "#{n*100+1}-" } 
      end
    end

    def navi_prev
      cur = loc.start.to_i
      if cur > 100
        a(:href=>loc.get_range(cur-100, cur))
      end
    end

    def navi_next
      cur = loc.to.to_i
      if cur + 100 < @articles_num
        a(:href=>loc.get_range(cur, cur+100))
      end
    end

    def navi_new
      a(:href=>loc.get_range(@articles_num, nil))
    end

    def navi_board
      a(:href=>loc.to_board(board.key))
    end

    def newarticle_form
      a(:action =>$amritabbs_config[:script_name]) do
        { 
          :theme=>a(:value=>loc.theme),
          :board_key=>a(:value=>loc.board),
          :thread=>a(:value=>threadid)
        }
      end
    end
  end

  module Article
    def name_with_mail
      a(:href=>"mailto:#{mail}") { name }
    end
  end
end

