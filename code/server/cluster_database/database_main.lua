
--[[
 * @brief: database_main.lua

 * @author:	  kun si
 * @date:	2017-01-05
--]]

local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local cluster = require "cluster"
require "skynet.manager"
require "sgoly_printf"
require "sgoly_query"
local service_config = require "sgoly_service_config"

skynet.start(function ()
	cluster.open("cluster_database")
	skynet.register("database_main")
	
	skynet.error("Cluster_database start")
	printI("Cluster_database start")

	local log = skynet.uniqueservice("sgoly_log")
	skynet.call(log, "lua", "start")

	

	skynet.uniqueservice("protoloader")
	if service_config["console"]["database"] == 1 then
		local console = skynet.newservice("console")
	end


	--local debug_port = skynet.getenv "debug_port"
	local debug_port = service_config["debug_port"]["database"]
	if debug_port then
		skynet.newservice("debug_console",debug_port)
	end


	local redispool = skynet.uniqueservice("redispool")
  	skynet.call(redispool, "lua", "start")

  	local mysqlpool = skynet.uniqueservice("mysqlpool")
  	skynet.call(mysqlpool, "lua", "start")

 	local res = mysql_query("select * from test")
 	for k, row in pairs(res) do
 		printI("row.id:%d row.test:%s", row.id, row.test)
 	end

 	skynet.uniqueservice("redisToMySQL")
	
end)