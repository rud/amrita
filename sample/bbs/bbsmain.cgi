#!/usr/local/bin/ruby
$KCODE = "e"
$:.unshift "."

require 'cgi'
require 'amrita/parts'
require 'bbs'

include Amrita

def setup_default
  $amritabbs_config = {} unless defined? $amritabbs_config
  $amritabbs_config[:data_dir] = 'data_ja'
  $amritabbs_config[:template_dir] = 'template'
  $amritabbs_config[:static_contents_dir] = nil
  $amritabbs_config[:default_theme] = 'simple'
  $amritabbs_config[:default_template] = 'top'
  $amritabbs_config[:advertize_html] = 'advertize_sample.html'
  $amritabbs_config[:script_name] = ENV['SCRIPT_NAME']
  $amritabbs_config[:themes] = %w(simple 2ch_ja 2ch_en slash_en kari_ja)

  $amritabbs_config[:max_thread_title] = 100
  $amritabbs_config[:max_thread_summary] = 5
  $amritabbs_config[:view_modules] = {} 

  $amritabbs_config[:debug_bbs] = false
  $amritabbs_config[:use_compiler] = true
  $amritabbs_config[:compiler_cache] = nil
  $amritabbs_inspect_object = [] 
end

def load_confiig
  conf = "#{ENV['SCRIPT_NAME']}.conf"
  conf = File::basename(conf)
  load conf if File::readable? conf
end

def setup_model(cgi)
  loc = BBS::Location::new_from_cgi(cgi)
  BBS::BBSModel.new(loc, $amritabbs_config[:data_dir], $amritabbs_config[:template_dir])
end

def main
  cgi = CGI.new
  cgi.print cgi.header

  setup_default
  load_confiig
  TemplateFileWithCache::set_cache_dir($amritabbs_config[:compiler_cache]) if $amritabbs_config[:use_compiler] and $amritabbs_config[:compiler_cache]

  bbs = setup_model(cgi)
  bbs.process_request(cgi.params)

rescue RuntimeError, ScriptError, ArgumentError, SystemCallError,Amrita::HtmlParseError
  cgi = STDERR unless cgi
  cgi.print e(:html) {
    [
      e(:h1) { "Error" },
      e(:p) { e(:font, :color=>"red") { $! } },
      e(:table)  { $@.collect { |l| e(:tr) { l.split.collect  { |c| e(:td) { c } } } } },
      e(:p) { cgi.inspect } ,
      e(:p) { $amritabbs_config.inspect } 
    ]
  }
ensure
  if $amritabbs_config[:debug_bbs]
    cgi.print e(:hr) + e(:h1) { "DEBUG INFORMATION" }+
      e(:p) { cgi.inspect } +
      e(:p) { $amritabbs_config.inspect } +
      $amritabbs_inspect_object.collect  { |x| e(:p) { x.inspect } }
  end
end

main
__END__
^L
Local Variables:
mode: ruby
coding: euc-japan
fill-column: 72
End:
