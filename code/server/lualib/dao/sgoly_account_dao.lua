--[[
 * @Version:     1.0
 * @Author:      GitHubNull
 * @Email:       641570479@qq.com
 * @github:      GitHubNull
 * @Description: 这是一个检查sgoly_account模块参数的模块
 * @DateTime:    2017-01-17 10:42:18
 --]]

 require "sgoly_printf"
 local account = require "sgoly_account"

 local account_dao = {}

 --[[
 函数说明：
 		函数作用：检查account.insert函数的参数并调用执行
 		传入参数：id(用户id), money(金币数额)
 		返回参数：执行结果的正确与否的布尔值和相关返回值
 --]]
 function account_dao.insert(id, money)
	local status = account.insert(id, money)
	if((0 == status.warning_count) and (1 == status.affected_rows)) then
		return true, "插入用户金币资产数据成功"
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查account.update_money函数的参数并调用执行
		传入参数：id(用户id), money(金币数额)
 		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function account_dao.update_money(id, money)
	local status = account.update_money(id, money)
	if((0 == status.warning_count) and (1 == status.affected_rows)) then
		return true, "更新用户金币资产数据成功"
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查account.select_money函数的参数并调用执行
		传入参数：id(用户id)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function account_dao.select_money(id)
	local status = account.select_money(id)
	if(1 == #status) then
		return true, status[1].money
	else
		return false, status.err
	end
end

 --!
 --! @brief      更新用户金钱
 --!
 --! @param      nickname  用户名
 --! @param      money     用户金钱
 --!
 --! @return     bool, table	执行是否成功、执行结果
 --!
 --! @author     kun si, 627795061@qq.com
 --! @date       2017-01-21
 --!
function account_dao.update_money_s(nickname, money)
	local status = account.update_money_s(nickname, money)
	if status.err then
		return false, status.err
	end

	return true, status
end

return account_dao