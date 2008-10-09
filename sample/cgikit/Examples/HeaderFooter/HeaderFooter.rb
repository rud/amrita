#
# HeaderFooter.rb
#

class HeaderFooter < CKComponent
	attr_accessor :title, :source
	
	def sourcePage
		sp = page "SourcePage"
		sp.source = fetch 'class'
		sp
	end
end


