#!/usr/local/bin/ruby

#
# Examples - examples of dynamic elements usage.
#

# $LOAD_PATH << '../cgikit'

require 'amrita/cgikit'

# resource directory includes image files ( cgikit.png )
resource = 'resource'

app = CKApplication.new
app.debug = true
app.resource = resource
app.run
