#!/usr/local/bin/ruby

class IndexPage < CKComponent
  include Amrita

  SystemPage = %w(Source Main Index HeaderFooter)

  def index
    Dir["*"].collect do |d|
      next unless d =~ /([A-Z]\w*)Page/
      target = $1
      next if SystemPage.member? target

      url = CKURL.new application
      url.target = d
      e(:a, :href=>url.url, :target=>"Contents") { target }
    end
      
  end
end
