
--[[
 * @brief: sgoly_tool.lua

 * @author:	  kun si
 * @date:	2017-01-12
--]]


require "sgoly_query"
local sgoly_tool = {}
local sgoly_dat_ser = require "sgoly_dat_ser"
local skynet = require "skynet"

--!
--! @brief      网络数据包取长度
--!
--! @param      str   网络网络数据包
--!
--! @return     网络数据包长度
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
function sgoly_tool.wordToInt(str)
	return str:byte(1) * 256 + str:byte(2)
end

--!
--! @brief      数值用两个字节存储
--!
--! @param      num   数值
--!
--! @return     两个字节的数值
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
function sgoly_tool.intToWord(num)
	local wordH = string.char(math.floor(num / 256))
	local wordL = string.char(num % 256)
	return wordH .. wordL	
end

--!
--! @brief      保存用户一键注册id
--!
--! @param      uuid  用户一键注册id
--!
--! @return     nil
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
local function saveUuid(uuid)
	redis_query({"set","uuid", uuid})
end

--!
--! @brief      查询用户一键注册id
--!
--! @return     用户一键注册id
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
local function getUuid()

	local uuid = redis_query({"get", "uuid"})
	return tonumber(uuid)
end

--!
--! @brief      Redis数字索引table转字符串索引
--!
--! @param      redisResult  Redis查询结果
--!
--! @return     bool, table		执行是否成功、转换结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
function sgoly_tool.multipleToTable(redisResult)

	if #redisResult <= 0 then
		printI("redisResult type[%s]", type(redisResult))
		return false, redisResult
	end
	local rt = {}
	local index = 1
	while index <= #redisResult-1 do
		rt[redisResult[index]] = redisResult[index+1]
		index = index + 2
	end 
	
	return true, rt 
end

--!
--! @brief      查询用户一键注册id
--!
--! @return     用户一键注册id
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
function sgoly_tool.getUuid()
	return getUuid()
end

--!
--! @brief      保存用户一键注册id
--!
--! @param      uuid  用户一键注册id
--!
--! @return     nil
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
function sgoly_tool.saveUuid(uuid)
	saveUuid(uuid)
end

--!
--! @brief      获得用户金钱
--!
--! @param      nickname  用户名
--!
--! @return     bool, money		执行是否成功、查询结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-16
--!
function sgoly_tool.getMoney(nickname)
	local db = "user:" ..  nickname
	local money = redis_query({"hget", db, "money"})
	if money then
		return true, tonumber(money)
	else
		local judge
		judge, money = sgoly_dat_ser.get_money(nickname)
		if judge then
			redis_query({"hset", db, "money", money})
			return true, money
		else
			return false, money
		end
	end
end

--!
--! @brief      保存用户总金币到Redis
--!
--! @param      nickname  用户名
--! @param      money     用户总金币
--!
--! @return     bool, errorMsg 执行成功与否、错误消息
--!
--! @author     kun si
--! @date       2017-01-16
--!
function sgoly_tool.saveMoneyToRedis(nickname, money)
	if nickname == nil or money == nil then
		return false, "nickname or money is nil"
	end
	
	local key = "user:" .. nickname
	redis_query({"hset", key, "money", money})
	return true, nil
end

--!
--! @brief      从Redis中获取结算信息
--!
--! @param      nickname  用户名
--!	@param		dt		  日期		 		
--!
--! @return     bool,table 执行成功与否、｛结算信息｝
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-19
--!
function sgoly_tool.getStatementsFromRedis(nickname, dt)
	if nickname == nil then
		return false, "There are nil in args."
	end
	local res = {}
	local key = "statements:" ..  nickname .. dt
	local res = redis_query({"hgetall", key})
	if #res > 0 then
		return sgoly_tool.multipleToTable(res)
	end

	local ok, result = sgoly_dat_ser.get_statments_from_MySQL(nickname, dt)
	if ok then
		result.eighthNoWin = eighthNoWin
		result.recoveryRate = recoveryRate
		if dt~= os.date("%Y-%m-%d") then
			result.saveStatementsToMySQL = 1
		else
			result.saveStatementsToMySQL = 1
		end
		redis_query({"hmset", key, result})
		return ok, result
	end
	return ok, result

end
--!
--! @brief      保存游戏结算结果到Redis
--!
--! @param      nickname      	用户名
--! @param      winMoney      	本轮游戏赢的金钱
--! @param      costMoney	  	本轮游戏消耗的金钱
--! @param		playNum			本轮游戏抽奖次数
--! @param      winNum        	本轮游戏中奖次数
--! @param      serialWinNum  	本轮游戏连续中奖次数
--! @param      maxWinMoney  	本轮游戏最大中奖金额	
--!	@param		eighthNoWin 	8次连续不中奖计数值
--!	@param		recoveryRate 	回收率
--!	
--! @return     bool, errorMsg 	执行成功与否、错误消息
--!
--! @author     kun si
--! @date       2017-01-16
--!
function sgoly_tool.saveStatementsToRedis(nickname, winMoney, costMoney, playNum, winNum, serialWinNum, maxWinMoney, eighthNoWin, recoveryRate, dt)
	if nickname == nil or winMoney == nil or 
		costMoney == nil or playNum == nil 
		or winNum == nil or serialWinNum == nil 
		or eighthNoWin == nil or recoveryRate == nil then

		return false, "There are nil in args."
	end
	
	local key = "statements:" .. nickname .. dt
	local ok, result = sgoly_tool.getStatementsFromRedis(nickname, dt)
	if ok then

		result.winMoney = result.winMoney + winMoney
		result.costMoney = result.costMoney + costMoney
		result.playNum = result.playNum + playNum
		result.winNum = result.winNum + winNum
		result.serialWinNum = serialWinNum
		result.maxWinMoney = maxWinMoney
		result.eighthNoWin = eighthNoWin
		result.recoveryRate = recoveryRate
		result.saveStatementsToMySQL = 0
		redis_query({"hmset", key, result})
		local ok , result = sgoly_dat_ser.update_statments_to_MySQL(nickname, result.winMoney, result.costMoney, result.playNum, result.winNum, result.maxWinMoney, result.serialWinNum, dt)
		return true, nil
	end

	return ok, result
end

--!
--! @brief      获取玩法改变模式的必要参数
--!
--! @param      nickname  用户名
--!
--! @return     bool,table 执行成功与否、｛8次连续不中奖计数值, 回收率｝
--!
--! @author     kun si
--! @date       2017-01-18
--!
function sgoly_tool.getPlayModelFromRedis(nickname)
	local res = {}
	local key = "statements:" ..  nickname .. os.date("%Y-%m-%d")
	res = redis_query({"hmget", key, "eighthNoWin", "recoveryRate"})
	if #res == 0 then
		res[1]=0
		res[2]=1
	end
	res[1]=tonumber(res[1])
	res[2]=tonumber(res[2])

	return true, res
end

--!
--! @brief      获得结算统计
--!
--! @param      nickname	用户名
--! @param 		dt			日期 
--!
--! @return     bool,table 执行成功与否、｛结算统计信息｝
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-20
--!
function sgoly_tool.getCountStatementsFromRedis(nickname, dt)
	local res = {}
	
	local key = "count:" .. nickname
	local res = redis_query({"hgetall", key})
	if #res > 0 then

		local ok1, result1 = sgoly_tool.multipleToTable(res)
		local ok2, result2 = sgoly_tool.getStatementsFromRedis(nickname, os.date("%Y-%m-%d"))
		local result3 = {
							winMoney = result1.winMoney+result2.winMoney, 
							costMoney = result1.costMoney+result2.costMoney, 
							playNum = result1.playNum+result2.playNum, 
							winNum = result1.winNum+result2.winNum,
							serialWinNum = result1.serialWinNum, 
							maxWinMoney = result1.maxWinMoney
						}

		if tonumber(result2.serialWinNum) > tonumber(result1.serialWinNum) then
			skynet.error(result2.serialWinNum, result1.serialWinNum)
			result3.serialWinNum = result2.serialWinNum
		end
		if tonumber(result2.maxWinMoney) > tonumber(result1.maxWinMoney) then
			result3.maxWinMoney = result2.maxWinMoney
		end
		return ok2, result3	
	end

	local ok, result = sgoly_dat_ser.get_count_statements_from_MySQL(nickname, dt)
	
	if ok then
		redis_query({"hmset", key, result})
		local ok2, result2 = sgoly_tool.getStatementsFromRedis(nickname, os.date("%Y-%m-%d"))
		local result3 = {
							winMoney = result.winMoney+result2.winMoney, 
							costMoney = result.costMoney+result2.costMoney, 
							playNum = result.playNum+result2.playNum, 
							winNum = result.winNum+result2.winNum, 
							serialWinNum = result.serialWinNum, 
							maxWinMoney = result.maxWinMoney
						}


		if tonumber(result2.serialWinNum) > tonumber(result.serialWinNum) then
			result3.serialWinNum = result2.serialWinNum
		end

		if tonumber(result2.maxWinMoney) > tonumber(result.maxWinMoney) then
			result3.maxWinMoney = result2.maxWinMoney
		end

		return ok, result3
	end

	return ok, result
	
end

--!
--! @brief      保存钱到MySQL
--!
--! @param      nickname	用户名
--! @return     bool, string  执行成功与否、错误信息
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-21
--!
function sgoly_tool.saveMoneyFromRdisToMySQL(nickname)
	local key = "user:" .. nickname
	local result = tonumber(redis_query({"hget", key , "money"}))
	if result < 0 then
		return false, "No money"
	end
	local ok , result = sgoly_dat_ser.upadate_money_to_MySQL(nickname, result)
	if ok then
		redis_query({"del", key})
	end
	return ok, result
end

--!
--! @brief      保存结算到MySQL
--!
--! @param      nickname	用户名
--! @param      dt			日期
--!
--! @return    bool, string  执行成功与否、错误信息
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-21
--!
function sgoly_tool.saveStatmentsFromRdisToMySQL(nickname, dt)
	local key1 = "count:" .. nickname
	local key2 = "statements:" .. nickname 
	local key3 = "user:" .. nickname
	local ok, result = sgoly_tool.getStatementsFromRedis(nickname, dt)
	if ok then
		skynet.error(string.format("have statements"))
			if tonumber(result.saveStatementsToMySQL) == 0 then 
			local ok , result = sgoly_dat_ser.update_statments_to_MySQL(nickname, result.winMoney, result.costMoney, result.playNum, result.winNum, result.maxWinMoney, result.serialWinNum, dt)
				if ok then
					redis_query({"del", key1})
					redis_query({"del", key2})
					redis_query({"del", key3})
				end
				skynet.error(ok, result)

				local yesterday = os.date("%Y-%m-") .. (tonumber(os.date("%d"))-1)
				sgoly_tool.saveStatmentsFromRdisToMySQL(nickname, yesterday)
			return ok, result
		end
	end
	skynet.error(string.format(" no have statements" .. dt))
	return ok ,result
	
end

return sgoly_tool