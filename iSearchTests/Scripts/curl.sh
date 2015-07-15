#!/bin/sh

#  curl.sh
#  iSearch
#
#  Created by lijunjie on 15/7/15.
#  Copyright (c) 2015年 Intfocus. All rights reserved.

#发送：
curl -l -H "Content-type: application/json" -X POST -d '{"UserId":"UserId001logapi","FunctionName":"FunctionName002logapi","ActionName":"ActionName002logapi","ActionTime":"2015-06-1 18:18:18","ActionReturn":"ActionReturn--092logapi","ActionObject":"ActionObject--003logapi"}' http://tsa-china.takeda.com.cn/uat/api/logjson.php
#返回结果：{"status":0,"result":""}
