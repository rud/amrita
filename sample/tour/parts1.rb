require 'amrita/parts'
include Amrita

module Elements
  class Header
    attr_reader :title
    def initialize(title)
      @title = title
    end
  end

  class List
    attr_reader :list
    def initialize(list)
      @list = list
    end
  end

  class RowData
    attr_reader :lang, :author, :url
    def initialize(lang, author, url)
      @lang, @author, @url = lang, author, url
    end
    
    def url_with_link
      e(:a, :href=>url) { url }
    end
  end
end
include Elements

parts_template = TemplateText.new <<END
<span class=Header>
  <h1 id=title></h1>  
</span>

<span class=List>
  <ul>
    <li id=list>
  </ul>
</span>

<span class=RowData>
  <tr>
    <td id=lang><td id=author><td id=url_with_link>
  </tr>
</span>
END

parts_template.install_parts_to(Elements)

document_template = TemplateText.new <<END
<html>
<body>
  <span id=header></span>
  <span id=list></span>

  <table> 
    <span id=tabledata></span>
  </table>
</body>
END

data = {
  :header=>Header.new("Scripting Languages"),
  :list=>List.new(%w(Ruby Perl Python)),
  :tabledata=> [
    RowData.new("Ruby", "matz", "http://www.ruby-lang.org/"),
    RowData.new("perl", "Larry Wall", "http://www.perl.com/"),
    RowData.new("python", "Guido van Rossum", "http://www.python.org/")
  ]
}

document_template.prettyprint = true
document_template.expand(STDOUT, data)
