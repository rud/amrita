#!/usr/local/bin/ruby

class TextFieldPage < CKComponent
	attr_accessor :value1, :value2, :value3
	
	def initialize(app,parent,name,body)
		super
		@value3 = 'I am hidden field.'
	end
end
