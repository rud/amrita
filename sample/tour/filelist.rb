
# amrita can use an existing class for model data.
# To show this ability, this sample uses Ruby's system class
# File::Stat.


require "amrita/template"
include Amrita

class File
  class Stat
    include Amrita::ExpandByMember

    def entry(name)
      a(:name=>name, :type=>ftype) { self }
    end

    def size_or_nil
      size if ftype == "file"
    end

    def mode_str
      ret = "-rwxrwxrwx"
      /(.*)(.)(.)(.)(.)(.)(.)(.)(.)(.)$/ =~ sprintf("%b",mode) 
      $~[2..10].each_with_index do |b,n|
        ret[n+1] = "-" if b != "1" 
      end
      ret[0] = "d" if $~[1] == "100000"
      ret 
    end

    def unix_inf
      a(:dev=>dev, :uid=>uid, :gid=>gid) { self }
    end
  end
end

tmpl = TemplateText.new <<END
  <file id="filelist">
     <size id="size_or_nil" />
     <mode id="mode_str" />
     <times>
       <ctime id="mtime" />
       <mtime id="mtime" />
       <atime id="atime" />
     </times>
     <unix_inf id="unix_inf">
        <inode id="ino" />
     </unix_inf>
  </file>
END

dir = ARGV.shift || '*'

filelist = Dir[dir].collect do |f|
  File::stat(f).entry(f)
end

data = { :filelist=>filelist }
tmpl.xml = true
tmpl.expand(STDOUT, data)

