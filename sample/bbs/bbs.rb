require 'amrita/parts'

require 'model'

def p(param)
  $amritabbs_inspect_object << param
  puts param.inspect if $amritabbs_config[:debug_bbs]
end

module BBS
  class Location
    attr_accessor :theme, :template, :board, :thread, :start, :to, :last
    def initialize
      @theme, @template = @board = @thread = @start = @to = @last = nil
    end

    def to_top
      ret = dup
      ret.board = ret.template = ret.thread = nil
      ret.start = ret.to = ret.last = nil
      ret
    end

    def theme_change(theme)
      theme = nil if theme == $amritabbs_config[:default_theme]
      ret = dup
      ret.theme = theme
      ret
    end

    def to_board(board)
      ret = dup
      ret.template = 'board'
      ret.board = board
      ret.thread = ret.start = ret.to = ret.last = nil
      ret
    end

    def to_thread(thread)
      ret = dup
      ret.template = 'thread'
      ret.start = ret.to = ret.last = nil
      ret.thread = thread
      ret
    end

    def get_all
      ret = dup
      ret.start = ret.to = ret.last = nil
      ret
    end

    def get_last(n)
      ret = dup
      ret.last = n
      ret
    end

    def get_range(start, to)
      ret = dup
      ret.start = ret.to = ret.last = nil
      ret.start = start
      ret.to = to
      ret
    end

    def to_s
      ret = "#{$amritabbs_config[:script_name]}?"
      ret += "&theme=#@theme" if @theme
      ret += "&template=#@template" if @template
      ret += "&board=#@board" if @board
      ret += "&thread=#@thread" if @thread
      ret += "&last=#@last" if @last
      ret += "&start=#@start" if @start
      ret += "&to=#@to" if @to
      ret
    end

    def Location::new_from_cgi(cgi)
      ret = new
      ret.theme = cgi['theme'][0]
      ret.theme = nil if ret.theme == ""
      ret.template = cgi['template'][0]
      ret.board = cgi['board'][0]
      ret.thread = cgi['thread'][0]
      ret.last = cgi['last'][0]
      ret.last = ret.last.to_i if ret.last
      ret.start = cgi['start'][0]
      ret.start = ret.start.to_i if ret.start
      ret.to = cgi['to'][0]
      ret.to = ret.to.to_i if ret.to
      ret
    end

    def select(ary)
      if last
        s = last < ary.size ? last : ary.size
        ary[(-1*s)..-1]
      else
        if start
          if to
            ary[(start-1)..(to-1)]
          else
            ary[(start-1)..-1]
          end
        else
          if to
            ary[0..(to-1)]
          else
            ary
          end
        end
      end
    end
  end

  class BBSModel
    include Amrita
    include ExpandByMember

    attr_reader :loc, :data_dir, :template_dir, :view_module

    def initialize(loc, data_dir, template_dir)
      @loc = loc
      @data_dir = data_dir
      @template_dir = template_dir
      setup_view
      setup_handlers
      setup_advertize
    end

    def template_path
      ret = File::join(@theme_dir, loc.template||$amritabbs_config[:default_template]) + ".html"
      unless File::readable? ret
        dir = File::join(@template_dir, $amritabbs_config[:default_theme]) 
        ret = File::join(dir, loc.template||$amritabbs_config[:default_template]) + ".html"
      end
      ret
    end

    def parts_template_path
      File::join(@theme_dir, "parts.html")
    end

    def data_path(board, path)
      case board
      when String
        dir = File::join(@data_dir, board)
        File::join(dir, path)
      when Board
        dir = File::join(@data_dir, board.key)
        File::join(dir, path)
      when nil
        File::join(@data_dir, path)
      else
        raise "can't happen"
      end
    end

    def setup_view
      @theme = loc.theme || $amritabbs_config[:default_theme]
      @theme_dir = File::join(@template_dir, @theme)
      
      require File::join(@theme_dir, "view.rb")
      @view_module = $amritabbs_config[:view_modules][@theme]
      raise "theme #{@theme} not found" unless @view_module
      install_view_module(self)
    end

    def install_view_module(obj, modname=nil)
      modname = obj.type.to_s.gsub(/([A-Z]\w*::)*([A-Z]\w*)/) { $2 } unless modname
      mod = @view_module.const_get(modname)
      obj.extend(mod) if mod
    rescue NameError
      STDERR.puts $!
      nil
    end

    def setup_handlers
      @handlers = [
        ViewHandler.new(self),
        NewArticleHandler.new(self),
        NewThreadHandler.new(self),
      ]
    end

    def process_request(params)
      handler = @handlers.find do |h|
        h.can_handle?(params)
      end
      raise "can't handle this request" unless handler
      handler.process_request(params)
    end

    def show_view
      if File::readable?(parts_template_path)
        t = TemplateFileWithCache.new(parts_template_path)
        t.install_parts_to(@view_module)
      end

      t = TemplateFileWithCache.new(template_path)
      t.use_compiler = $amritabbs_config[:use_compiler] 
      #t.debug_compiler = true
      t.install_parts_to(@view_module)
      t.expand($stdout, self)
    end

    def boardlist
      unless defined? @boardlist
        @boardlist = BoardList.new(self)
      end
      @boardlist
    end

    def current_board
      boardlist.get_board(loc.board)
    end

    def current_thread
      current_board.get_thread(loc.thread)
    end

    def setup_advertize
      @advertize = []
      if $amritabbs_config[:advertize_html] and File::readable?($amritabbs_config[:advertize_html])
        a = Amrita::HtmlParser::parse_file($amritabbs_config[:advertize_html])
        @advertize = a.find_all { |e| e.tagname_symbol == :div and e[:class] == "advertize" }
      end
    end

    def advertize_random
      r = rand(@advertize.size)
      @advertize[r]
    end

    def theme_selecter
      $amritabbs_config[:themes].collect do |t|
        e(:a, :href=>loc.theme_change(t)) { t }
      end
    end

    def whatnew
      ret = {}
      ret[:boards] = []
      all_thread=boardlist.categories.each do |c|
        ret[:boards] += c.boards.collect do |b|
          next if b.url
          link = e(:a, :href=>loc.to_board(b.key)) { b.name }
          path = data_path(b.key, "subject.txt")
          next unless File::readable? path
          mtime = File::stat(path).mtime
          {
            :link => link,
            :mtime => mtime
          }
        end
      end
      ret[:boards].delete_if { |b| b == nil}
      ret[:boards].sort! { |a,b| a[:mtime] <=> b[:mtime] }
      
      ret
    end
  end
  
  class HandlerBase
    attr_reader :model

    def initialize(model)
      @model = model
    end
  end

  class ViewHandler < HandlerBase
    def can_handle?(param)
      param["action"][0] == nil
    end

    def process_request(param)
      model.show_view
    end
  end

  class ModelUpdateHandler < HandlerBase
    def get_thread_key(board)
      Time.new.to_i.to_s
    end

    def lock(&block)
      path = model.data_path(nil, "board.txt")
      File::open(path) do |f|
        f.flock(File::LOCK_EX) 
        begin
          yield(f)
        ensure
          f.flock(File::LOCK_UN) 
        end
      end
    end
    
    def put_subject(board, key, subject)
      path1 = model.data_path(board, "subject.txt")
      path2 = model.data_path(board, "subject.txt.sav")

      unless subject
        File::open(path1) do |f|
          f.each do |l|
            if l =~ /#{key}.dat<>(.*)/
              subject = $1
              break
            end
          end
        end
      end
      File::rename(path1, path2)
      File::open(path1, "w") do |newf|
        newf.puts("#{key}.dat<>#{subject}")
        File::open(path2) do |oldf|
          oldf.each do |l|
            next if l =~ /#{key}/
            newf.print l
          end
        end
      end
    end

    def put_article(board, key, name, mail, message)
      path = model.data_path(board, "#{key}.dat")
      File::open(path, "a") do |f|
        f.puts "#{name}<>#{mail}<>#{Time.new}<>#{message}"
      end
    end

    def sanitize_text(text)
      if text
        ret = text.amrita_sanitize
        ret.gsub!(/http:\S+/) { "<a href=\"#{$~}\">#{$~}</a>" }
        ret.gsub!(/\r\n|\n/, "<br>")
        ret
      else
        text
      end
    end

    def redirect_response(url)
      e(:html)  {
        e(:head) {
          e(:meta, "http-equiv"=>"refresh", :content=>"0;URL=#{url}")
        } +
          e(:body) {
          [
            "wait a second or click here-->",
            e(:a, :href=>url) { url }
          ]
        }
      }
    end
  end

  class NewThreadHandler < ModelUpdateHandler
    def can_handle?(param)
      param["action"][0] == "newthread"
    end

    def process_request(cgi)
      lock do
      board = sanitize_text(cgi['board'][0])
      name = sanitize_text(cgi['from'][0])
      mail = sanitize_text(cgi['mail'][0])
      subject = sanitize_text(cgi['subject'][0])
      message = sanitize_text(cgi['message'][0])
      raise "no data" unless board and board != ""
      raise "no data" unless name and name != ""
      raise "no data" unless subject and subject != ""
      raise "no data" unless message and message != ""

      key = get_thread_key(board)
      put_subject(board, key, subject) unless mail == "sage"
      put_article(board, key, name, mail, message)

      print redirect_response(model.loc.to_board(board))
      end
    end
  end

  class NewArticleHandler < ModelUpdateHandler
    def can_handle?(param)
      param["action"][0] == "newarticle"
    end

    def process_request(cgi)
      lock do
      board = sanitize_text(cgi['board'][0])
      thread = sanitize_text(cgi['thread'][0])
      name = sanitize_text(cgi['from'][0])
      mail = sanitize_text(cgi['mail'][0])
      message = sanitize_text(cgi['message'][0])
      raise "no data" unless board and board != ""
      raise "no data" unless thread and thread != ""
      raise "no data" unless message and message != ""

      put_subject(board, thread, nil) unless mail == "sage"
      put_article(board, thread, name, mail, message)

      print redirect_response(model.loc.to_board(board))
      end
    end
  end
end

