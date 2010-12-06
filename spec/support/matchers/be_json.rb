RSpec::Matchers.define :be_json do
  match do |actual|
    begin
      JSON.parse(actual)
      true
    rescue
      false
    end
  end
end
