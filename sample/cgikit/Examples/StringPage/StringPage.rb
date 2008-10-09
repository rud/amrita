#!/usr/local/bin/ruby

class StringPage < CKComponent
	attr_accessor :variable
	
	def initialize(app,parent,name,body)
		super
		@variable = 'I am variable of StringPage.'
	end
	
	def method
		'I am method of StringPage.'
	end
end
