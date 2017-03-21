--[[
 * @Version:     1.0
 * @Author:      GitHubNull
 * @Email:       641570479@qq.com
 * @github:      GitHubNull
 * @Description: 数据管理模块
 * @DateTime:    2017-01-17 16:33:15
 --]]

local users = require "sgoly_users"
local account = require "sgoly_account"
local day_io = require "sgoly_day_io"
local day_max = require "sgoly_day_max"
local day_times = require "sgoly_day_times"
-- local union_query_server = require "sgoly_union_query_server"
-- local uuid_server = require "sgoly_uuid_server"
-- local rank_server = require "sgoly_rank_server"
local safe = require "sgoly_safe"
local head = require "sgoly_head"
local sign_in = require "sgoly_sign_in"
local award = require "sgoly_award"
local skynet = require "skynet"
local union_query = require "sgoly_union_query"
local sgoly_uuid = require "sgoly_uuid"
local sgoly_rank = require "sgoly_rank"
local prop = require "sgoly_prop"
local prop_att = require "sgoly_prop_att"


local dat_ser = {}

function tabLen(tab)
	local cnt = 0
	if(nil == tab) then
		return cnt
	end
	for k, v in pairs(tab) do
		cnt = cnt + 1
	end
	return cnt
end

--[[
函数说明：
		函数作用：用户注册
		传入参数：nickname(用户昵称), pwd(密码)
		返回参数：ture和成功提示信息 或者 false 和错误信息
--]]
function dat_ser.register(nickname, pwd)
	printD("dat_ser.register(%s, %s)", nickname, pwd)
	printI("dat_ser.register(%s)", nickname)

	local status1, tab = users.select(nickname)
	local tl = tabLen(tab)
	if(1 <= tl) then
		return false, "昵称已被使用"
	end

	local status2, msg2 = users.insert(nickname, pwd)
	printD(" status2 = %s", status2)

	--	init users users account
	local type = "register"
	local status3, money = award.select_money(type)
	local status4, uid = users.select_uid(nickname)
	printD("Register  uid[%s]", uid)
	local status5, msg5 = account.insert(uid, money)
	printD(" status5 = %s", status5)

	--	init users head
	local img_name = "1"
	local path = "usersHead"
	local status6, msg6 = head.insert(uid, img_name, path)
	printD(" status6 = %s", status6)

	local status = (status2 and status5 and  status6)
	if(true == status) then
		return true, "注册成功"
	else
		printD("status =%s", status)
		return false, "注册失败"
	end
end

--[[
函数说明：
		函数作用：用户登录
		传入参数：nickname(用户你从), pwd(密码)
		返回参数：ture和成功提示信息 或者 false 和错误信息
--]]
function dat_ser.login(nickname, pwd)
	printD("dat_ser.login(%s, %s)", nickname, pwd)
	printI("dat_ser.login(%s)", nickname)

	local status1, tab = users.select(nickname)
	if(false == status1) then
		return false, "用户不存在"
	elseif(tab.pwd ~= pwd) then
		return false, "密码错误"
	else
		return true, tab.id
	end
end

--[[
函数说明：
		函数作用：get users id
		传入参数：nickname
		返回参数：(false, err_msg) or (true, true_value)
--]]
function dat_ser.get_uid(nickname)
	return users.select_uid(nickname)
end

--[[
函数说明：
		函数作用：get users nickname
		传入参数：uid(users id)
		返回参数：(false, err_msg) or (true, value)
--]]
function dat_ser.get_nickname(uid)
	printD("dat_ser.get_nickname(%d)", uid)
	return users.select_nickname(uid)
end

--[[
函数说明：
		函数作用：更改用户的昵称
		传入参数：old_nic(旧昵称), new_nick()新昵称, pwd(密码)
		返回参数：ture和成功提示信息 或者 false 和错误信息
--]]
function dat_ser.cha_nic(old_nic, new_nick, pwd)
	printD("dat_ser.cha_nic(%s, %s, %s)", old_nic, new_nick, pwd)
	printI("dat_ser.cha_nic(%s, %s, %s)", old_nic, new_nick, pwd)

	local status1, tab = users.select(old_nic)
	if(0 == #tab) then
		return false, "用户不存在"
	elseif(tab.pwd ~= pwd) then
		return false, "密码错误"
	else
		local status2, msg = users.update_nickname(tab.id, new_nick)
		if(true == status2) then
			return false, "更改昵称成功"
		else
			return true, "更改昵称失败"
		end
	end
end

--[[
函数说明：
		函数作用：更改用户的密码
		传入参数：uid(用户id), old_pwd(旧的密码), new_pwd(新密码)
		返回参数：ture和成功提示信息 或者 false 和错误信息
--]]
function dat_ser.cha_pwd(uid, old_pwd, new_pwd)
	printD("dat_ser.cha_pwd(%d, %s, %s)", uid, old_pwd, new_pwd)
	printI("dat_ser.cha_pwd(%d, %s, %s)", uid, old_pwd, new_pwd)
	local status1, pwd = users.select_pwd(uid)
	if(pwd ~= old_pwd) then
		return false, "旧密码错误"
	else
		local status2, msg2 = users.update_pwd(uid, new_pwd)
		if(true == status2) then
			return true, "更改帐号密码成功"
		else
			return false, "更改帐号密码失败"
		end
	end
end

--[[
函数说明：
		函数作用：dell users and users conf
		传入参数：nickname(用户昵称), pwd(密码)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.del_usr(nickname, pwd)
	printD(" dat_ser.del_usr(%s, %s)", nickname, pwd)
	printI(" dat_ser.del_usr(%s, %s)", nickname, pwd)

	local status1, tab = users.select(nickname)
	if(nil == tab) then
		return false, "用户不存在"
	elseif(tab.pwd ~= pwd) then
		return false, "密码错误"
	else
		local status2, msg2 = users.delete(nickname)
		if(true == status2) then
			return true, "删除帐号成功"
		else
			return false, "删除帐号失败"
		end
	end
end

--[[
函数说明：
		函数作用：获得排名对应的赢得的金币数额
		传入参数：award_name(排名项目名字), id(名次)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.get_award(award_name, id)
	printD("dat_ser.get_award(%s, %d)", award_name, id)
	printI("dat_ser.get_award(%s, %d)", award_name, id)

	local type = award_name.."-"..id
	local status1, money = award.select_money(type)
	if(true == status1) then
		return true, money
	else
		return false, "未知错误"
	end
end

--[[
函数说明：
		函数作用： get users account money
		传入参数： id(users id)
		返回参数： (false, err_msg) or (true, true_value)
--]]
function dat_ser.get_money(id)
	printD("dat_ser.get_money(%d)", id)
	printI("dat_ser.get_money(%d)", id)

	return account.select_money(id)
end

--[[
函数说明：
		函数作用： 更新用户账户金币数额
		传入参数： id(users id), money(金币数额)
		返回参数： (false, err_msg) or (true, true_msg)
--]]
function dat_ser.upd_acc(id, money)
	printD("dat_ser.up_acc(%d, %d)", id, money)
	printI("dat_ser.up_acc(%d, %d)", id, money)

	return account.update_money(id, money)
end

--!
--! @brief      查询用结算
--!
--! @param      nickname  用户名
--! @param      dt        日期
--!
--! @return     bool, table	执行是否成功、执行结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-20
--!
function dat_ser.get_statments_from_MySQL(nickname, dt)
	printD("dat_ser.get_statements_from_mysql(%s)", nickname)
	printI("dat_ser.get_statements_from_mysql(%s)", nickname)
	if not nickname or not dt then
		return false, "Args nil"
	end

	local ok, result = union_query.get_statments_from_MySQL(nickname, dt)
	if ok and #result > 0 then

		return ok,
		{
			winMoney = result[1].win,
			costMoney = result[1].cost,
			playNum = result[1].times,
			winNum = result[1].win_times,
			maxWinMoney = result[1].single_max,
			serialWinNum = result[1].conti_max,
		}

	end
	
	local today = os.date("%Y-%m-%d")

	if dt == today then
		day_io.insert(nickname, 0, 0, today)
		day_times.insert(nickname, 0, 0, today)
		day_max.insert(nickname, 0, 0, today)
	end

	return true,
	{
		winMoney = 0,
		costMoney = 0,
		playNum = 0,
		winNum = 0,
		maxWinMoney = 0,
		serialWinNum = 0,
	}
end

--!
--! @brief      更新用户结算
--!
--! @param      nickname      用户名
--! @param      winMoney      中奖金额
--! @param      costMoney     消耗金额
--! @param      playNum       抽奖次数
--! @param      winNum        中奖次数
--! @param      maxWinMoney   最大中奖金额
--! @param      serialWinNum  连续中奖次数
--! @param      dt            日期
--!
--! @return     bool, table	执行是否成功、执行结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-20
--!
function dat_ser.update_statments_to_MySQL(nickname, winMoney, costMoney, playNum, winNum, maxWinMoney, serialWinNum, dt)
	if not nickname or not dt then
		return false, "Args nil"
	end
	local ok, result = day_io.updateS(nickname, winMoney, costMoney, dt)
	if not ok then
		printE("error:%s", reslut)
		return ok, result
	end

	ok, result = day_times.updateS(nickname, playNum, winNum, dt)
	if not ok then
		printE("error:%s", reslut)
		return ok, result
	end

	ok, result = day_max.updateS(nickname, maxWinMoney, serialWinNum, dt)
	if not ok then
		printE("error:%s", reslut)
		return ok, result
	end

	return true, "Save statments to MySQL success"
	
end


--!
--! @brief      统计用户结算
--!
--! @param      nickname  用户名
--!
--! @return     bool, table	执行是否成功、执行结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-21
--!
function dat_ser.get_count_statements_from_MySQL(nickname, dt)
	if not nickname then
		return false, "Args nil"
	end
	local ok, result = union_query.get_count_statements_from_MySQL(nickname, dt)
	if ok and #result > 0 then
		return ok,
		{
			winMoney = result[1].win,
			costMoney = result[1].cost,
			playNum = result[1].times,
			winNum = result[1].win_times,
			maxWinMoney = result[1].single_max,
			serialWinNum = result[1].conti_max,
		}
	elseif #result ==0 then

		return ok,
		{
			winMoney = 0,
			costMoney = 0,
			playNum = 0,
			winNum = 0,
			maxWinMoney = 0,
			serialWinNum = 0,
		}
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
function dat_ser.upadate_money_to_MySQL(nickname, money)
	local ok, result = account.update_money_s(nickname, money)
	return ok, result
	
end

--!
--! @brief      查询用户一键注册自增长id
--!
--! @return     bool, table		执行是否成功、查询结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-21
--!
function dat_ser.select_uuid()
	return sgoly_uuid.select_uuid()
end

--!
--! @brief      更新用户一键注册自增长id
--!
--! @param      uuid  用户一键注册自增长id
--!
--! @return     bool, table		执行是否成功、查询结果
--! 
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-21
--!
function dat_ser.update_uuid(uuid)
	return sgoly_uuid.update_uuid(uuid)
end

--!
--! @brief      保存排行榜到MySQL
--!
--!	@paaram		rank_type 	排行榜类型
--! @param      rank  		排行榜table
--! @param      args  		用户数据table
--! @param      date  		日期
--!
--! @return     bool, string		执行是否成功、查询结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-24
--!
function dat_ser.save_rank_to_MySQL(rank_type, rank, args, date)
	return sgoly_rank.save_rank_to_MySQL(rank_type, rank, args, date)
end

--!
--! @brief      从MySQL中查询排行榜
--!
--! @param      rank_type  排行绑类型 "serialWinNum"或"winMoney"
--! @param      date       The date
--!
--! @return     bool, table		执行是否成功、查询结果
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-01-24
--!
function dat_ser.get_rank_from_MySQL(rank_type, date)
	return sgoly_rank.get_rank_from_MySQL(rank_type, date)
end

--[[
函数说明：
		函数作用：检查用户是否已设置保险柜密码
		传入参数：uid(用户id)
		返回参数：(false, err_msg) or (true, true_value)
--]]
function dat_ser.seted_safe_pwd(uid)
	printD("dat_ser.seted_safe_pwd(%d)", uid)
	printI("dat_ser.seted_safe_pwd(%d)", uid)
	local tag, status = safe.select(uid)
	if( false == tag) then
		return false, status
	else
		if(nil == status) then
			return false, "未设置保险柜密码"
		else
			return true, "已设置保险柜密码"
		end
	end
end

--[[
函数说明：
		函数作用：设置保险柜密码
		传入参数：uid(用户id), passwd(用户保险柜密码)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.set_safe_pwd(uid, passwd)
	printD("dat_ser.set_safe_pwd(%d, %s)", uid, passwd)
	printI("dat_ser.set_safe_pwd(%d)", uid)
	local init_saf_money = 0
	return safe.insert(uid, passwd, init_saf_money)
end

--[[
函数说明：
		函数作用：打开保险柜
		传入参数：uid(用户id), passwd(用户保险柜密码)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.open_saf(uid, passwd)
	printD("dat_ser.open_saf(%d, %s)", uid, passwd)
	printI("dat_ser.open_saf(%d)", uid)
	local tag, status = safe.select_passwd(uid)
	if(false == tag) then
		return false, status
	else
		if(status == passwd) then
			return true, "保险柜打开成功"
		else
			return false, "保险柜打开不成功"
		end
	end
end

--[[
函数说明：
		函数作用： 查询保险柜余额
		传入参数： uid(用户id)
		返回参数： (false, err_msg) or (true, true_value)
--]]
function dat_ser.query_saf_money(uid)
	printD("dat_ser.query_saf_money(%d)", uid)
	printI("dat_ser.query_saf_money(%d)", uid)
	return safe.select_money(uid)
end

--[[
函数说明：
		函数作用：存金币到保险柜
		传入参数：uid(用户id), money(金币数额)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.save_money_2saf(uid, money)
	printD("dat_ser.save_money_2saf(%d, %d)", uid, money)
	printI("dat_ser.save_money_2saf(%d, %d)", uid, money)
	local tag1, src_money = safe.select_money(uid)
	if(false == tag1) then
		return false, src_money
	end
	local dst_money = src_money + money
	local tag2, status = safe.update_money(uid, dst_money)
	if(false == tag2) then
		printD("dat_ser.save_money_2saf() 存钱失败 status = %s", status)
		return false, "存金币失败"
	else
		return true, "存金币成功"
	end
end

--[[
函数说明：
		函数作用：从保险柜取出金币
		传入参数：uid(用户id), money(金币数额)
		返回参数：(false, err_msg) or (true, 要取数额)
--]]
function dat_ser.get_saf_money(uid, money)
	printD("dat_ser.get_saf_money(%d, %d)", uid, money)
	printI("dat_ser.get_saf_money(%d, %d)", uid, money)
	local tag1, src_money = safe.select_money(uid)
	if(false == tag1) then
		return false, src_money
	end
	if(src_money < money) then
		return false, "取金币失败,余额小于要取数额"
	end
	local dst_money = src_money - money
	local tag2, status = safe.update_money(uid, dst_money)
	if(false == tag2) then
		printD("dat_ser.get_saf_money() 取金币失败 status = %s", status)
		return false, "取金币失败"
	else
		return true, money
	end
end

--[[
函数说明：
		函数作用： 更改保险柜密码
		传入参数： uid(用户id), old_pwd(旧密码), new_pwd(新密码)
		返回参数： (false, err_msg) or (true, true_msg)
--]]
function dat_ser.cha_saf_pwd(uid, old_pwd, new_pwd)
	printD("dat_ser.cha_saf_pwd(%d, %s, %s)", uid, old_pwd, new_pwd)
	printI("dat_ser.cha_saf_pwd(%d)", uid)
	local status, src_pwd = safe.select_passwd(uid)
	if(false == status) then
		return false, "修改密码失败"
	end

	if(src_pwd ~= old_pwd) then
		return false, "旧密码不正确"
	end

	local status2, msg = safe.update_passwd(uid, new_pwd)
	if(true == status2) then
		return true, "修改密码成功"
	else
		return false, msg
	end
end

--[[
函数说明：
		函数作用：设置用户头像
		传入参数：uid(用户id), img_name(头像名称), path(头像路径, 可为空值)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.set_head(uid, img_name, path)
	if(nil ~= path) then
		printD("dat_ser.set_head(%d, %s, %s)", uid, img_name, path)
		printI("dat_ser.set_head(%d, %s, %s)", uid, img_name, path)
	else
		printD("dat_ser.set_head(%d, %s)", uid, img_name)
		printI("dat_ser.set_head(%d, %s)", uid, img_name)
	end
	local status, msg = head.insert(uid, img_name, path)
	if(true == status) then
		return true, "设置头像成功"
	else
		return false, msg
	end
end

--[[
函数说明：
		函数作用：更改用户头像名称
		传入参数：uid(用户id), new_img_name(新头像名称)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.cha_img_name(uid, new_img_name)
	printD("dat_ser.cha_img_name(%d, %s)", uid, new_img_name)
	printI("dat_ser.cha_img_name(%d, %s)", uid, new_img_name)
	local status, msg = head.update_img_name(uid, new_img_name)
	if(true == status) then
		return true, "修改头像成功"
	else
		return false, msg
	end
end

--[[
函数说明：
		函数作用：更改头像路径
		传入参数：uid(用户id) new_path(新头像路径)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.cha_path(uid, new_path)
	printD("dat_ser.cha_path(%d, %s)", uid, new_path)
	printI("dat_ser.cha_path(%d, %s)", uid, new_path)
	local status, msg = head.update_path(uid, new_path)
	if(true == status) then
		return true, "修改头像路径成功"
	else
		return false, msg
	end
end

--[[
函数说明：
		函数作用：获取用户头像名称
		传入参数：uid(用户id)
		返回参数：(false, err_msg) or (true, true_values)
--]]
function dat_ser.get_img_name(uid)
	printD("dat_ser.get_img_name(%d)", uid)
	printI("dat_ser.get_img_name(%d)", uid)
	return head.select_img_name(uid)
end

--[[
函数说明：
		函数作用：获取用户头像路径
		传入参数：uid(用户id)
		返回参数：(false, err_msg) or (true, true_values)
--]]
function dat_ser.get_img_path(uid)
	printD("dat_ser.get_img_path(%d)", uid)
	printI("dat_ser.get_img_path(%d)", uid)
	return head.select_path(uid)
end

--[[
函数说明：
		函数作用：签到
		传入参数：uid(用户id), date(日期)
		返回参数：(false, err_msg) or (true, true_msg)
--]]
function dat_ser.sign(uid, date)
	printD("sign_in.sign(%d, %s)", uid, date)
	printI("sign_in.sign(%d, %s)", uid, date)
	local status, msg = sign_in.insert(uid, date)
	if(true == status) then
		return true, "签到成功"
	else
		return false, "签到失败"
	end
end

--[[
函数说明：
		函数作用：查询签到情况
		传入参数：uid(用户id)
		返回参数：(false, err_msg) or (true, value(最近的7天 k-date 键值对))
--]]
function dat_ser.query_sign(uid)
	printD("dat_ser.query_sign(%d)", uid)
	printI("dat_ser.query_sign(%d)", uid)
	return sign_in.select_date(uid)
end

--!
--! @brief      Sets the user online.
--!
--! @param      uid   The uid
--! @param      addr  The address
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-02-16
--!
function dat_ser.set_user_online(uid, addr, isOnline)
	return union_query.set_user_online(uid, addr, isOnline)
end

--!
--! @brief      Sets the user exit.
--!
--! @param      uid   The uid
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-02-16
--!
function dat_ser.set_user_exit(uid)
	return union_query.set_user_exit(uid)
end

--[[
函数说明：
		函数作用： get users all prop
		传入参数： uid(user id)
		返回参数： (true, value) or (false, err_msg)
--]]
function dat_ser.get_all_prop(uid)
	printD("dat_ser.get_all_prop(%d)", uid)
	printI("dat_ser.get_all_prop(%d)", uid)
	return prop.select(uid)
end

--[[
函数说明：
		函数作用： set users prop value
		传入参数： uid(user id), type(the type of prop), 
				  value(the value of type prop)
		返回参数： (true, true_msg) or (false, err_msg)
--]]
function dat_ser.set_prop(uid, type, value)
	printD("dat_ser.set_prop(%d, %d, %d)", uid, type, value)
	printI("dat_ser.set_prop(%d, %d, %d)", uid, type, value)
	return prop.insert(uid, type, value)
end

--[[
函数说明：
		函数作用： get prop att
		传入参数： id(prop id)
		返回参数： (true, value) or (false, err_msg)
--]]
function dat_ser.get_prop_att(id)
	printD("dat_ser.get_prop_att(%d)", id)
	printI("dat_ser.get_prop_att(%d)", id)
	return prop_att.select(id)
end

--!
--! @brief      Saves a probability to my sql.
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-02-24
--!
function dat_ser.saveProbabilityToMySQL(type, modle)
	union_query.saveProbabilityToMySQL(type, modle)
end

--!
--! @brief      Gets the probability from my sql.
--!
--! @param      type  The type
--!
--! @return     The probability from my sql.
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-02-24
--!
function dat_ser.getProbabilityFromMySQL(type)
	return union_query.getProbabilityFromMySQL(type)
end

--!
--! @brief      Sets the user login time.
--!
--! @param      username  The username
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-02-24
--!
function dat_ser.setUserLoginTime(uid)
	return union_query.setUserLoginTime(uid)
	
end

--!
--! @brief      Sets the user logout time.
--!
--! @param      uid   The uid
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-02-24
--!
function dat_ser.setUserLogoutTime(uid)
	return union_query.setUserLogoutTime(uid)
end

--!
--! @brief      { function_description }
--!
--! @param      uid     The uid
--! @param      number  The number
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-03-20
--!
function dat_ser.update_recharge(uid, number)
	return account.update_recharge(uid, number)
end

--!
--! @brief      Gets the recharge.
--!
--! @param      uid   The uid
--!
--! @return     The recharge.
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-03-20
--!
function dat_ser.get_recharge(uid)
	return account.get_recharge(uid)
end

--!
--! @brief      Sets the property used.
--!
--! @param      uid   The uid
--! @param      type  The type
--! @param      used  The used
--!
--! @return     { description_of_the_return_value }
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-03-21
--!
function dat_ser.setPropUsed(uid, type, used)
	return prop.setPropUsed(uid, type, used)
end

--!
--! @brief      Gets the property used.
--!
--! @param      uid   The uid
--! @param      type  The type
--!
--! @return     The property used.
--!
--! @author     kun si, 627795061@qq.com
--! @date       2017-03-21
--!
function dat_ser.getPropUsed(uid, type)
	return prop.getPropUsed(uid, type)
end

return dat_ser
