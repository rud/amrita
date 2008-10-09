require 'open3'
require 'amrita/template'

TIME_CMD='/usr/bin/time -f "%S %U" '

def do_bench1(cmd)
  i,o,e = *Open3.popen3(TIME_CMD + cmd)
  i.close
  result = o.read
  # p result
  ret = e.read
  if ret =~ /([\d\.]+)\s*([\d\.]+)/
    [$1.to_f, $2.to_f]
  else
    raise "unexpected result #{ret}"
  end
end

def get_loading_overhead
  ret = do_bench1("ruby -r amrita/template -e 'print 1'")
end

def do_bench(n)
  ENV["CNT"] = n.to_s
  cmds = [
    ["interpreter", "ruby amrita.rb #{n} ", true],
    ["preformat", "ruby amrita.rb #{n} preformat", true],
    ["compiler", "ruby amrita.rb #{n} compiler", true],
    ["use hint", "ruby amrita.rb #{n} usehint", true],
    ["eruby", "eruby eruby.rhtml"],
    ["plain ruby", "ruby plain.rb #{n}"],
  ]

  loading_overhead = get_loading_overhead
  puts "overhead of loading amrita/template => #{loading_overhead.inspect}"
  puts "this time will be recuced from result of amrita"
  cmds.collect do |title, cmd, minus_loading_overhead|
    print "start #{title}..."
    ret = do_bench1(cmd)
    p ret
    if minus_loading_overhead
      ret[0] -= loading_overhead[0]
      ret[1] -= loading_overhead[1]
    end
    {
      :title=>title,
      :system=>sprintf("%4.2f", ret[0]),
      :user=>sprintf("%4.2f", ret[1]),
      :total=>sprintf("%4.2f", (ret[0] + ret[1])),
      :one_tran=>sprintf("%4.2f", ((ret[0] + ret[1])*1000)/n.to_f)
    }
  end
end

def report(data)
  tmpl = Amrita::TemplateText.new <<-END
  <html>
    <body>
      <h1>amrita benchmark</h1>
      <table>
        <tr><th>title<th>system<th>user<th>total<th>one transaction(MS)
        <tr id=data><td id=title><td id=system align=right><td id=user align=right><td id=total align=right><td id=one_tran align=right>
      </table>
    </body>
  </html>
  END

  IO.popen("w3m -T text/html -dump", "w") do |f|
    tmpl.expand(f, data)
  end
end

ret = do_bench(ARGV.shift || 10)

report(:data=>ret)
