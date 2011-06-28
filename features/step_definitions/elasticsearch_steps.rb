Given /^elasticsearch index$/ do
  Rake.application["elasticsearch"].invoke
end

Given /^an indexed database$/ do
  JSON.parse(RestClient.get(@db.to_s + '/_all_docs?include_docs=true'))['rows'].each do |row|
    doc = row['doc']
    next if doc['_id'][0] == '_' # design document
    RestClient.put CONFIG['es'] +'/stops/'+ @db_name +'/'+ doc.delete("_id"), doc.to_json
  end
  RestClient.post CONFIG['es'] +'/stops/_refresh', nil do |resp|; end
end
