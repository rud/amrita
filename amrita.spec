%define amrita_current_ver 1.0.2
%if !0%{?ruby:1}
%define ruby ruby
%endif
%if !0%{?rbdir:1}
%define rbdir sitedir
%endif
%if !0%{?rblibdir:1}
%define rblibdir %(%{ruby} -rrbconfig -e "puts Config::CONFIG['%{rbdir}']")
%endif

Summary: amrita -- a html/xhtml template library for Ruby
Name: amrita
Version: %{amrita_current_ver}
Release: 1
Copyright: GPL

Url: http://www.brain-tokyo.jp/research/amrita/
Group: Development/Libraries
Source0: %{url}amrita-%{amrita_current_ver}.tar.gz
Buildroot: /var/tmp/amrita
BuildArchitectures: noarch
AutoReqProv: no
Prefix: %(%{ruby} -rrbconfig -e "puts Config::CONFIG['prefix']")

%changelog
* Fri Aug 5 2002 Taku Nakajima <tnakajima@brain-tokyo.jp>
- added bin/ams

* Fri Jul 19 2002 Taku Nakajima <tnakajima@brain-tokyo.jp>
- apply patch from Nobu Nakata

* Tue Jul  9 2002 Taku Nakajima <tnakajima@brain-tokyo.jp>
- first release

%description
a html/xhtml template library for Ruby

%prep
%setup

%build

%install
rm -rf $RPM_BUILD_ROOT

make %{?srcdir:-C %{srcdir}} install \
	PREFIX=$RPM_BUILD_ROOT%{prefix} SITE_DIR=$RPM_BUILD_ROOT%{rblibdir}


%files
%defattr(-, root, root)

%{rblibdir}/amrita/compiler.rb
%{rblibdir}/amrita/format.rb
%{rblibdir}/amrita/tag.rb
%{rblibdir}/amrita/parser.rb
%{rblibdir}/amrita/node_expand.rb
%{rblibdir}/amrita/node.rb
%{rblibdir}/amrita/template.rb
%{rblibdir}/amrita/ams.rb
%{rblibdir}/amrita/xml.rb
%{rblibdir}/amrita/amx.rb
%{rblibdir}/amrita/handlers.rb
%{rblibdir}/amrita/cgikit.rb
%{rblibdir}/amrita/merge.rb
%{rblibdir}/amrita/parts.rb
%{prefix}/bin/ams
%{prefix}/bin/amx
%{prefix}/bin/amshandler

%clean
rm -rf $RPM_BUILD_ROOT
