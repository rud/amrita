#!/usr/local/bin/ruby

class ConditionalPage < CKComponent
	attr_accessor :isShow

	def initialize(app,parent,name,body)
		super
		@isShow = true
	end

	def inspectVersion
                if @isShow
			CKApplication.version
		else
			nil
		end
	end

	def showInspect
		@isShow = true
	end

	def hideInspect
		@isShow = false
	end
end
