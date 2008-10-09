require "amrita/template"
include Amrita


TEMPLATE = <<END
<html>
<head>
<title id="title"></title>
</head>
<body>
<h1 id="title"></h1>
<table border="1">
  <tr><th>name</th><th>author</th><th>webpage</tr>
  <tr id="table">
    <td id="name"></td>
    <td id="author"></td>
    <td><a id="webpage"></a></td>
  </tr>
</table>
</body>
</html>
END

table = File::open("bench.dat").collect do |line|
  items = line.chomp.split('|')
  {
    :name=>items[0],
    :author=>items[1],
    :webpage=> a(:href=>items[2]) { items[3] },
  }
end


data = {
  :title => 'amrita benchmark',
  :table => table
}

cnt = ARGV.shift.to_i

tmpl = TemplateText.new(TEMPLATE)
case ARGV.shift
when "preformat"
  tmpl.pre_format = true
when "compiler"
  tmpl.use_compiler = true
when "usehint"
  tmpl.use_compiler = true
  tmpl.set_hint_by_sample_data(data)
end

cnt.times  do
  tmpl.expand(STDOUT, data)  # without compiling
end

