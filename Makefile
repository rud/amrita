

VERS=1.0.2
PREFIX=/usr/local
RUBY_VER=1.6
#SITE_DIR=$(PREFIX)/lib/ruby/site_ruby/${RUBY_VER}
#SITE_DIR=$(PREFIX)/lib/ruby/${RUBY_VER}
SITE_DIR=$(PREFIX)/lib/site_ruby/${RUBY_VER}
BIN_DIR=$(PREFIX)/bin
#RPMROOT=$(HOME)/redhat
RPMROOT=$(HOME)/rpm
DOCDIR=$(PREFIX)/share/doc/amrita/html

all : ;

install :
	install -d $(SITE_DIR)/amrita
	install -m 644 lib/amrita/compiler.rb $(SITE_DIR)/amrita/compiler.rb
	install -m 644 lib/amrita/format.rb $(SITE_DIR)/amrita/format.rb
	install -m 644 lib/amrita/node.rb $(SITE_DIR)/amrita/node.rb
	install -m 644 lib/amrita/node_expand.rb $(SITE_DIR)/amrita/node_expand.rb
	install -m 644 lib/amrita/parser.rb $(SITE_DIR)/amrita/parser.rb
	install -m 644 lib/amrita/tag.rb $(SITE_DIR)/amrita/tag.rb
	install -m 644 lib/amrita/template.rb $(SITE_DIR)/amrita/template.rb
	install -m 644 lib/amrita/ams.rb $(SITE_DIR)/amrita/ams.rb
	install -m 644 lib/amrita/xml.rb $(SITE_DIR)/amrita/xml.rb
	install -m 644 lib/amrita/amx.rb $(SITE_DIR)/amrita/amx.rb
	install -m 644 lib/amrita/cgikit.rb $(SITE_DIR)/amrita/cgikit.rb
	install -m 644 lib/amrita/merge.rb $(SITE_DIR)/amrita/merge.rb
	install -m 644 lib/amrita/handlers.rb $(SITE_DIR)/amrita/handlers.rb
	install -m 644 lib/amrita/parts.rb $(SITE_DIR)/amrita/parts.rb
	install -d $(BIN_DIR)
	install -m 755 bin/ams $(BIN_DIR)/ams
	install -m 755 bin/amshandler $(BIN_DIR)/amshandler
	install -m 755 bin/amx $(BIN_DIR)/amx
          
tar: src_clean 
	$(MAKE) rdoc DOCDIR=docs/html
	rm -f amrita-$(VERS).tar.gz
	@ls $(SRC) | sed s:^:amrita-$(VERS)/: >MANIFEST
	@(cd ..; ln -s amrita_stable amrita-$(VERS))
	(cd ..; tar -czvf amrita_stable/amrita-$(VERS).tar.gz `cat amrita_stable/MANIFEST` --exclude CVS --exclude debian)
	@(cd ..; rm amrita-$(VERS) )

test_it : 
	rm -f sample.log
	(cd test; ruby -w -I../lib testall.rb)
	(cd sample/hello; for f in *.rb ;do echo $$f ; ruby -w -I../../lib $$f; done) >> sample.log 
	(cd sample/tour; for f in *.rb ;do echo $$f ; ruby -w -I../../lib $$f ; done) >> sample.log 
	(cd sample/tour; RUBYLIB=../../lib ../../bin/ams amstest.ams >> ../../sample.log);
	(cd sample/tour; RUBYLIB=../../lib ../../bin/amx amxtest.xml >> ../../sample.log);
	(cd docs; RUBYLIB=../lib ../bin/amx index.xml >> ../sample.log);
	(cd docs; RUBYLIB=../lib ../bin/amx index_ja.xml >> ../sample.log); # you need rexml 2.5.1 and uconv for this test

profile_it : 
	(cd test; ruby -r profile.rb -I../lib testall.rb)

rdoc: 
	rdoc --op $(DOCDIR) -S --main README README docs/QuickStart  docs/Tour docs/Tour2 docs/XML docs/Cgi lib/amrita README_ja docs/QuickStart_ja docs/Tour_ja docs/XML_ja docs/Tour2_ja docs/Cgi_ja
	(cd $(DOCDIR)/files/; ruby -i.back -ne 'print gsub("iso-8859-1", "EUC-JP") unless /<?xml/' *ja.html)	
	(cd $(DOCDIR)/files/docs/; ruby -i.back -ne 'print gsub("iso-8859-1", "EUC-JP") unless /<?xml/' *ja.html)	

src_clean :
	rm -rf docs/html
	find . -name '*~' -exec rm {} \;
rpm: tar
	cp amrita-$(VERS).tar.gz $(RPMROOT)/SOURCES
	cp amrita.spec $(RPMROOT)/SPECS
	rpm -ba $(RPMROOT)/SPECS/amrita.spec

rpm_reinstall: rpm
	sudo rpm -e amrita --nodeps || true
	sudo rpm -i $(RPMROOT)/RPMS/noarch/amrita-$(VERS)-1.noarch.rpm || true
	rm -f amrita-$(VERS).tar.gz

deb: src_clean
	dpkg-buildpackage -rsudo

deb_reinstall: deb
	sudo dpkg -i ../amrita_$(VERS)-0.1_all.deb
