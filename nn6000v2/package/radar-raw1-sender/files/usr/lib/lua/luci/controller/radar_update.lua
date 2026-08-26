module("luci.controller.radar_update", package.seeall)

function index()
	entry({"admin", "services", "radar_update"}, call("action_index"), _("Radar 更新"), 91).dependent = false
end

function action_index()
	local http = require "luci.http"
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	local result
	local update_url = uci:get("radar-raw1-sender", "main", "update_url") or ""
	if http.formvalue("save") then
		update_url = http.formvalue("update_url") or ""
		uci:set("radar-raw1-sender", "main", "update_url", update_url)
		uci:commit("radar-raw1-sender")
		result = "更新地址已保存"
	end
	if http.formvalue("update") then
		result = sys.exec("/usr/bin/radar-raw1-update 2>&1")
	end
	luci.template.render("radar_update", { result = result, update_url = update_url })
end
