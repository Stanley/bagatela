Given /^build index$/ do
  FileUtils.cd File.dirname(__FILE__) +'/../../utils/picky' do
    require 'active_support/core_ext'
    Rake::Task[:'index:randomly'].invoke
  end
end
