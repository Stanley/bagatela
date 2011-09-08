When /^I send a ([A-Z]{3,6}) request to http:\/\/api\.bagate\.la(\/.+[^\s])$/ do |method, uri, body=nil|
  url = API + URI.escape(uri)
  @response = begin
    RestClient::Request.execute method: method, url: url, payload: body
  rescue => e
    e.response
  end
end

When /^I send a ([A-Z]{3,6}) request to http:\/\/graph\.bagate\.la(\/.+[^\s])$/ do |method, uri, body=nil|

  Node = @nodes
  Relationship = @relationships

  module Compatibility
    def to_s
      body.
        gsub(/\/(node|relationship)\/(\d+)/) do 
          "/#{$1}/#{eval($1.capitalize).find{|key,val| val.id.to_s == $2}[0]}"
        end
    end
    def code; status end
  end

  def fix(str)
    str.gsub(/node\/(\d+)/){"node/#{@nodes[$1].id}"}
  end

  # replace fake ids with the real ones
  real_uri = fix(uri)
  body = fix(body) unless body.nil?

  browser = Rack::Test::Session.new(Rack::MockSession.new(RestApi.new))
  browser.request(URI.escape(real_uri), :method=>method, :input=>body)

  @response = browser.last_response
  @response.extend Compatibility
end

Then /^the response status should be (\d+)$/ do |status|
  @response.code.should eql(status.to_i)
end

Then /^the response should be:$/ do |json|
  JSON.parse(@response.to_s).should eql(JSON.parse(json))
end

Then /^the response without ([\_a-z]+) should be:$/ do |ommit, json|
  JSON.parse(@response.to_s).reject{|key, value| ommit == key }.should eql(JSON.parse(json))
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
