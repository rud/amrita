#!/usr/local/bin/ruby

#
# HelloWorld.cgi - Sample application for CGIKit
#

# $LOAD_PATH.push( '../cgikit' )

require 'amrita/cgikit'

app = CKApplication.new
app.run
