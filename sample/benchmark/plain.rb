
$title = 'amrita benchmark'

$data = File::open("bench.dat").collect do |line|
  line.chomp.split('|')
end


def doit
  print <<END
<html>
<head>
<title>#{$title}</title>
</head>
<body>
<h1>#{$title}</h1>
<table border="1">
  <tr><th>name</th><th>author</th><th>webpage</tr>
END

  $data.each do |items|
  print <<-END
  <tr>
    <td>#{items[0]}</td>
    <td>#{items[1]}</td>
    <td><a href="#{items[2]}">#{items[3]}</a></td>
  </tr>
  END
end

  print <<END
</table>
</body>
</html>
END
end

cnt = ARGV.shift.to_i
cnt.times { doit }
