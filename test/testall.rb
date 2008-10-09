
require 'runit/testcase'
require 'runit/cui/testrunner'

load 'testnode.rb'
load 'testexpand.rb'
load 'testformat.rb'
load 'testformat2.rb'
load 'testparser.rb'
load 'testcompiler.rb'
load 'testtemplate.rb'
load 'testxml.rb'
load 'testams.rb'
load 'testmerge.rb'
load 'testparts.rb'

suite = RUNIT::TestSuite.new

ObjectSpace.each_object(Class) do |klass|
  if klass.ancestors.include?(RUNIT::TestCase)
    suite.add_test(klass.suite)
  end
end

RUNIT::CUI::TestRunner.quiet_mode = false
if RUNIT::CUI::TestRunner.run(suite).succeed?
  puts "every test OK"
else
  exit(1)
end

