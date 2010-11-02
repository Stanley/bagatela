Given /^an empty database "([^\"]{2})"$/ do |db|
  @db = RestClient::Resource.new COUCH+db
  @db.delete do; end
  @db.put nil
end

Given /^a design document "([A-Z][a-z]+)"$/ do |document|
  view = File.join(File.dirname(__FILE__), '..', '..', 'views', document.downcase+'.json')
  @db['_design/'+document].put File.read(view), :content_type => 'application/json'
end

# Given /^design documents$/ do
#   Dir[File.join(File.dirname(__FILE__), '..', '..', 'views', '*.json')].each do |view|
#     name = view.split('/').last.gsub('.json', '').capitalize
#     @db['_design/'+name].put File.read view, :content_type => 'application/json'
#   end
# end

Given /^the following ([a-z]+)s:$/ do |type, resources|
  resources.hashes.each do |resource|
    resource['type'] = type.capitalize
    resource['table'] = JSON.parse resource['table'] if resource['table']
    @db.post resource.to_json, :content_type => 'application/json'
  end
end