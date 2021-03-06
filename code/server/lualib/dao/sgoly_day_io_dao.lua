--[[
 * @Version:     1.0
 * @Author:      GitHubNull
 * @Email:       641570479@qq.com
 * @github:      这是一个检查 sgoly_day_io 模块参数的模块
 * @Description: This is about...
 * @DateTime:    2017-01-17 11:33:08
 --]]

 require "sgoly_printf"
 local day_io = require "sgoly_day_io"

 local day_io_dao = {}

--[[
函数说明：
		函数作用：检查 day_io.insert 函数参数,并调用执行
		传入参数：uid(用户id), win(赢得的金币数额), cost(花费的金币数额), dt(日期)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function day_io_dao.insert(uid, win, cost, dt)
	local status = day_io.insert(uid, win, cost, dt)
	if((0 == status.warning_count) and (1 == status.affected_rows)) then
		return true, "插入用户当日收支数据成功"
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查 day_io.update_win 函数参数,并调用执行
		传入参数：uid(用户id), win(赢得的金币数额), dt(日期)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function day_io_dao.update_win(uid, win, dt)
	local status = day_io.update_win(uid, win, dt)
	if((0 == status.warning_count) and (1 == status.affected_rows)) then
		return true, "更新用户当日收入数据成功"
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查 day_io.update_cost 函数参数,并调用执行
		传入参数：uid(用户id), cost(花费的金币数额), dt(日期)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function day_io_dao.update_cost(uid, cost, dt)
	local status = day_io.update_cost(uid, cost, dt)
	if((0 == status.warning_count) and (1 == status.affected_rows)) then
		return true, "更新用户当日支出数据成功"
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查 day_io.select 函数参数,并调用执行
		传入参数：uid(用户id),  dt(日期)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function day_io_dao.select(uid, dt)
	local status = day_io.select(uid, dt)
	if(1 == #status) then
		return true, status[1]
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查 day_io.select_win 函数参数,并调用执行
		传入参数：uid(用户id),  dt(日期)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function day_io_dao.select_win(uid, dt)
	local status = day_io.select_win(uid, dt)
	if(1 == #status) then
		return true, status[1].win
	else
		return false, status.err
	end
end

--[[
函数说明：
		函数作用：检查 day_io.select_cost 函数参数,并调用执行
		传入参数：uid(用户id),  dt(日期)
		返回参数：执行结果的正确与否的布尔值和相关返回值
--]]
function day_io_dao.select_cost(uid, dt)
	local status = day_io.select_cost(uid, dt)
	if(1 == #status) then
		return true, status[1].cost
	else
		return false, status.err
	end
end

 --!
 --! @brief      更新当天用户中将金币
 --!
 --! @param      nickname  用户名
 --! @param      win       中奖金额
 --! @param      cost      消耗金额
 --! @param      dt        日期
 --!
 --! @return     bool, table		执行是否成功、执行结果
 --!
 --! @author     kun si, 627795061@qq.com
 --! @date       2017-01-21
 --!
function day_io_dao.updateS(nickname, win, cost, dt)
	local status = day_io.updateS(nickname, win, cost, dt)
	if status.err then
		return false, status.err
	end

	return true, status
end

return day_io_dao