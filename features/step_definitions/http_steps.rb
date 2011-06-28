When /^I send a ([A-Z]{3,6}) request to http:\/\/api\.bagate\.la\/(.+[^\:])$/ do |method, uri|
  @response = begin
    RestClient.send method.downcase, API+URI.escape(uri)
  rescue => e
    e.response
  end
end

When /^I send a ([A-Z]{3,6}) request to http:\/\/api\.bagate\.la\/(.+[^\s]):$/ do |method, uri, body|
  @response = begin
    RestClient::Request.execute method: method.to_sym, url: API+URI.escape(uri), payload: body
  rescue => e
    e.response
  end
end

Then /^the response status should be (\d+)$/ do |status|
  @response.code.should eql(status.to_i)
end

Then /^the response should be:$/ do |json|
  JSON.parse(@response).should eql(JSON.parse(json))
end

Then /^the response without ([\_a-z]+) should be:$/ do |ommit, json|
  JSON.parse(@response).reject{|key, value| ommit == key }.should eql(JSON.parse(json))
end

Then /^the response without rows' ([\_a-z]+).([\_a-z]+) should be:$/ do |value, ommit, json|
  resp = JSON.parse(@response)
  resp['rows'] = resp['rows'].map do |doc|
    doc[value] = doc[value].reject{|key, _| ommit == key }
    doc
  end
  resp.should eql(JSON.parse(json))
end

Then /^the result should be stops?: (.+)$/ do |ids|
  JSON.parse(@response)['hits']['hits'].map{|hit| hit['_id'] }.should eql(ids.split(', '))
end
