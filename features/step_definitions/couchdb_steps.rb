Given /^an empty database "([^\"]+)"$/ do |db|
  @db = RestClient::Resource.new API+db
  @db_name = db
  @db.delete do; end
  @db.put '', {'Content-Length' => 0}
end

Given /^design documents$/ do
  Rake.application["couchdb:views"].reenable
  Rake.application["couchdb:views"].invoke(@db_name)
end

Given /^the following ([a-z]+)s:$/ do |type, resources|
  resources.hashes.each do |resource|
    resource['type'] = type.capitalize
    ['table', 'polylines', 'location'].each do |key|
      resource[key] = JSON.parse resource[key] if resource[key]
    end
    @db.post resource.to_json, :content_type => 'application/json'
  end
end

