
--[[
 * @brief: sgoly_tool.lua

 * @author:	  kun si
 * @date:	2017-01-12
--]]


require "sgoly_query"
local sgoly_tool = {}
local sgoly_dat_ser = require "sgoly_dat_ser"

function sgoly_tool.wordToInt(str)
	return str:byte(1) * 256 + str:byte(2)
end

function sgoly_tool.intToWord(num)
	local wordH = string.char(math.floor(num / 256))
	local wordL = string.char(num % 256)
	return wordH .. wordL	
end
--

local function saveUuid(uuid)
	redis_query({"set","uuid", uuid})
end

local function getUuid()

	local uuid = redis_query({"get", "uuid"})
	return tonumber(uuid)
end

function sgoly_tool.multipleToTable(redisResult)
	local rt = {}
	local index = 1
	while index <= #redisResult-1 do
		rt[redisResult[index]] = redisResult[index+1]
		index = index + 2
	end 

	return rt 
end

function sgoly_tool.getUuid()
	return getUuid()
end

function sgoly_tool.saveUuid(uuid)
	saveUuid(uuid)
end

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
function sgoly_tool.saveStatementsToRedis(nickname, winMoney, costMoney, playNum, winNum, serialWinNum, maxWinMoney, eighthNoWin, recoveryRate)
	if nickname == nil or winMoney == nil or 
		costMoney == nil or playNum == nil 
		or winNum == nil or serialWinNum == nil 
		or eighthNoWin == nil or recoveryRate == nil then

		return false, "There are nil in args."
	end
	
	local key = "statements:" .. nickname
	redis_query({"hmset", key, {

			"winMoney", winMoney, 
			"costMoney", costMoney, 
			"playNum", playNum, 
			"winNum", winNum, 
			"serialWinNum", serialWinNum, 
			"maxWinMoney", maxWinMoney,
			"eighthNoWin", eighthNoWin,
			"recoveryRate", recoveryRate,

		}})

	return true, nil
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
	local key = "statements:" ..  nickname
	res = redis_query({"hmget", key, "eighthNoWin", "recoveryRate"})
	if #res == 0 then
		res[1]=0
		res[2]=0
	end

	return true, res
end

return sgoly_tool