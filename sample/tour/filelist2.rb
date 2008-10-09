#!/usr/bin/ruby

require "amrita/template"
include Amrita

$exclude = %w( CVS index.html)
$tmpl = TemplateText.new <<END
<html>
  <head>
    <title id="title"></title>
  </head>
  <body>
    <h1 id="title"></h1>
    <hr>
    <table>
      <tr>  <th>Type<th>Name<th>Size </tr>
      <tr id="filelist">
        <td id="filetype"><td id="name"><td id="size" align="right">
      </tr>
    </table>
    <hr>
    <a href="../index.html">parent directory</a>
  </body>
</html>
END

class File
  class Stat
    include Amrita::ExpandByMember
    attr_accessor :name
    
    def filetype
      case ftype
      when "directory"
        "[DIR]"
      when "file"
        "[   ]"
      else
        raise "unknown file type #{ftype}"
      end
    end
  end
end

def make_filelist(dir=nil)
  puts dir
  d = Dir::pwd
  Dir::chdir dir if dir
  l = Dir['*'].collect do |f|
    next if $exclude.member? f
    s = File::stat(f)
    path = f
    path += "/index.html" if s.ftype == "directory"
    s.name = e(:a, :href=>path) { f } 
    make_filelist(f) if s.ftype == "directory"
    s
  end

  data = {
    :title => dir,
    :filelist=>l
  }
  File::open("index.html", "w") do |f|
    $tmpl.expand(f, data)
  end
ensure
  Dir::chdir d
end

make_filelist
