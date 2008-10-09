((<English|URL:index.html>))

= amrita home page

== amrita とはなにか？

amrita(アムリタ)は Ruby用のhtml/xhtmlテンプレートライブラリーです。
テンプレートとモデルデータをかけあわせてHTMLドキュメントを出力します。

特色

* アムリタのテンプレートは<?...?> or <% .. %>等の特殊なタグを含まない
  普通のHTML文書です。
  
* テンプレートは一般的なHTMLエディタを使用して作成、修正することができます。

* 静的なパートだけでなく、動的なパートの見ためを変更してもRubyのコードを
  変更する必要はありません。

* モデルデータは、Hash, Array, String等のRubyの標準データです。自作のク
  ラスをモデルデータにすることもできます。

* 出力はロジックでなくデータによって制御されます。そのため、テストが非常
  しやすく、eXtreamProgramingに向いています。

* 必要ならば実行の前にテンプレートをRubyのコードにコンパイルすることもで
  きます


詳しくは((<ドキュメント|URL:rdocs>))(英語)か
((<クイックスタートガイド日本語版|URL:rdocs/files/docs/QuickStart_ja.html>))
を参照してください。
http://kari.to/amrita/l
== ダウンロード

* ((<stable version(V0.8.4)|URL:amrita-0.8.4.tar.gz>))

   注意! V0.8.1はXSS脆弱性があるので使用しないで下さい!

* cvs repository

    $ cvs -d ":pserver:guest@kari.to:/home/cvs/root" login 
     password: (no password type just return)
    $ cvs -d ":pserver:guest@kari.to:/home/cvs/root" co amrita

* ((<ソースを見る|URL:sources>))

* ((<更新記録|URL:sources/ChangeLog>))

== デモ

* ((<bookmark.rb|URL:sources/sample/cgi/bookmark.rb>))を
  ((<URL:http://kari.to/amrita/cgi-bin/bookmark.cgi>))で実行しています
