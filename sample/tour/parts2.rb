require 'amrita/parts'
include Amrita

module ElementView
  # the parts template will be installed here
end

module Elements
  class RowData
    attr_reader :lang, :author, :url
    def initialize(lang, author, url, very_cool=false)
      @lang, @author, @url = lang, author, url
      if very_cool
        extend ElementView::RowDataForCoolLanguage
      else
        extend ElementView::RowData
      end
    end
    
    def url_with_link
      e(:a, :href=>url) { url }
    end
  end
end
include Elements

parts_template = TemplateText.new <<END
<span class=RowData>
  <tr>
    <td id=lang><td id=author><td><span id=url></span>(no need to visit)</td>
  </tr>
</span>

<span class=RowDataForCoolLanguage>
  <tr>
    <td><b id=lang></b><td><strong id=author></strong><td id=url_with_link>
  </tr>
</span>
END

parts_template.install_parts_to(ElementView)

document_template = TemplateText.new <<END
<html>
<body>
  <table>
    <tr><th>name<th>author<th>url</tr> 
    <span id=tabledata></span>
  </table>

<div align=right><font size=-1>....It's only a joke! Don't be angry.</font></div>
</body>
END

data = {
  :tabledata=> [
    RowData.new("perl", "Larry Wall", "http://www.perl.com/"),
    RowData.new("Ruby", "matz", "http://www.ruby-lang.org/", true), 
    RowData.new("python", "Guido van Rossum", "http://www.python.org/")
  ]
}

document_template.prettyprint = true
document_template.expand(STDOUT, data)
