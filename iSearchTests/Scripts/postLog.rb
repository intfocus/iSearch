require "rest-client"
require "json"
url = "https://tsa-china.takeda.com.cn/uat/api/logjson.php"

hash = { UserId: "1", 
  FunctionName: "functionName", 
  ActionName: "actionName", 
  ActionTime: "2015-06-1 18:18:18", 
  ActionReturn: "actionReturn", 
  ActionObject: "actionObject" 
  }
puts hash

response = RestClient.post url, hash.to_json
puts response.headers