require 'active_support/core_ext'

Given /^built index$/ do
  PICKY_ENVIRONMENT = "test"
  FileUtils.cd File.dirname(__FILE__) +'/../../utils/picky' do
    require 'picky'
    require './app/application'
    Indexes.index true
  end
end
