require "rest-client"
require "json"

url = "http://www.pgyer.com/apiv1/app/view"
params = {
  aKey: "com.intfocus.iSearch",
  _api_key: "45be6d228e747137bd192c4c47d4f64a"
}
response = RestClient.post url, params.to_json
puts response.inspect