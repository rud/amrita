#!/usr/bin/ruby

require 'cgi'
require 'amrita/template'
require 'bmmodel'
include Amrita

DATAFILE_PATH="bookmark.dat"
TEMPLATE_PATH="bookmark.html"
CACHE_PATH="/tmp/bookmark"

class Item
  include Amrita::ExpandByMember

  def link
    e(:a, :href=>@url) { @url }
  end
end

def make_model_data(bm, selected_group)
  groups = bm.groups.keys.sort

  data = {
    :groups => groups.collect do |k|
      {
        :group_name=>k,
        :items=>bm.groups[k].collect do |item|
          {
            :name => item.name,
            :link => e(:a, :href=>item.url) { item.url }
          }
        end
      }
    end ,
    :form => {
      :group_sel=>e(:select, :name=>"group_sel") {
        groups.collect do |g|
          if g == selected_group
            e(:option, :value=>g, :selected=>"selected") { g }
          else
            e(:option, :value=>g) { g }
          end
        end
      },
    }
  }

  data
end

def generate_output(bm, group)
  #Amrita::TemplateFileWithCache::set_cache_dir(CACHE_PATH)
  tmpl = Amrita::TemplateFileWithCache[TEMPLATE_PATH]
  tmpl.use_compiler = true
  tmpl.expand($stdout, make_model_data(bm,group))
end

def main
  bm = BookmarkList.new
  bm.load_from_file(DATAFILE_PATH)
  cgi = CGI.new
  url = cgi['url'][0]
  group = ""
  if url
    group = (cgi['group'][0]).to_s
    group = (cgi['group_sel'][0]).to_s if group == ""
    name = (cgi['title'][0]).to_s 
    name = url if name == ""
    bm.add_new_item(group, name, url)
    bm.save_to_file(DATAFILE_PATH)
  end
  puts cgi.header
  generate_output(bm, group)
end

main
