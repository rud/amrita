#
# MainPage.rb
#

class MainPage < CKComponent
	attr_reader :name, :isMyName, :list, :index, :item
	attr_writer :item, :index

	def list
		@list = ['ruby','perl','python','java','c']
		@index = 0
		@item = ''
		return @list
	end

	def setMyName( myName )
		@myName = myName
		@isMyName = "true"
	end

	def sayHello
		@name = @myName
		return
	end
end


