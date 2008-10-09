#!/usr/local/bin/ruby

class RepetitionPage < CKComponent
  attr_accessor :list, :item, :index

  def initialize(app,parent,name,body)
    super
    @list = [ 'Ruby', 'Perl', 'Python', 'PHP', 'Java' ]
  end
  
  def inspectList
    @list.inspect
  end

  def amritalist
    (0...@list.size).collect do |i|
      {
        :title => "List#{i}:",
        :item  => @list[i]
      }
    end
  end
end
