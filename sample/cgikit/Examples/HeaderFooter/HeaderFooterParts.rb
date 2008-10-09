#
# HeaderFooter.rb
#

class HeaderFooterParts < CKComponent
	include CKPartsMaker

	attr_accessor :title, :source

	def query
		hash = {}
		hash['source'] = source
		hash
	end

	def source
		unless @source
			"#@title\Page"
		else
			@source
		end
	end

	def sourcePage
		sp = page "SourcePage"
		sp.source = application.request['source']
		sp
	end
end

