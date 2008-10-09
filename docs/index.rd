((<Japanese|URL:index_ja.html>))

= amrita home page

== What is amrita ?

Amrita is a a html/xhtml template library for Ruby. 
It makes html documents from a template and a model data.

Key feature

* The template for amrita is a pure html/xhtml document without 
  special tags like <?...?> or <% .. %>

* The template can be written by designers using almost any HTML
  Editor.

* Need no change on Ruby code to change the view of ((*dynamic*)) part
  (not only static part) of the template

* The model data may be standard Ruby data, Hash, Array, String... or
  an instance of a classes you made.

* The output is controlled by ((*data*)) no by logic. So It's easy to
  write, test, debug code. (Good for eXtreamPrograming)

* HTML template can be compiled into Ruby code before execution
  with a little effort.

Amrita mixes a template and model data up to a html document naturally
matching the +id+ attribute of HTML element to model data.

For detail see ((<documents|URL:rdocs>))

== download

* ((<stable version(V0.8.4)|URL:amrita-0.8.4.tar.gz>))

  CAUTION! amrita-0.8.1.tar.gz has a XSS vulnerability. Don't use it.

* cvs repository

    $ cvs -d ":pserver:guest@kari.to:/home/cvs/root" login 
     password: (no password type just return)
    $ cvs -d ":pserver:guest@kari.to:/home/cvs/root" co amrita

* ((<see sources|URL:sources>))

* ((<see ChangeLog|URL:sources/ChangeLog>))

== demo

* ((<bookmark.rb|URL:http://kari.to/amrita/cgi-bin/bookmark.cgi>))

  ((<see source|URL:http://kari.to/amrita/sources/sample/cgi/bookmark.rb>))

