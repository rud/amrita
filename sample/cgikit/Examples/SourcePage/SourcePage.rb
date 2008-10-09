#!/usr/local/bin/ruby

class SourcePage < CKComponent
	attr_accessor :source

	def _body( suffix )
		if application.locale == 'ja' and suffix == 'html' then
			file = "./#@source/#@source\_ja.#{suffix}"
		else
			file = "./#@source/#@source.#{suffix}"
		end
		File.new( file ).readlines.join
	end

	def htmlFile
		_body "html"
	end

	def definitionFile
		_body "ckd"
	end

	def rubyFile
		_body "rb"
	end
end
