module("luci.controller.radar_update", package.seeall)

function index()
	entry({"admin", "services", "radar_update"}, call("action_index"), _("Radar 更新"), 91).dependent = false
	entry({"admin", "services", "radar_update", "start"}, call("action_update_start")).leaf = true
	entry({"admin", "services", "radar_update", "status"}, call("action_update_status")).leaf = true
end

local function write_json(data)
	local http = require "luci.http"
	http.prepare_content("application/json")
	http.write_json(data)
end

function action_index()
	local http = require "luci.http"
	local sys = require "luci.sys"
	local util = require "luci.util"
	local result
	local update_url = sys.exec("uci -q get radar-raw1-sender.main.update_url 2>/dev/null"):gsub("%s+$", "")
	if http.formvalue("save") then
		update_url = http.formvalue("update_url") or ""
		sys.exec("uci set radar-raw1-sender.main.update_url=" .. util.shellquote(update_url) .. " && uci commit radar-raw1-sender")
		result = "更新地址已保存"
	end
	luci.template.render("radar_update", { result = result, update_url = update_url })
end

function action_update_start()
	local sys = require "luci.sys"
	if sys.call("test -d /var/run/radar-raw1-update.lock") == 0 then
		write_json({ ok = false, error = "更新任务正在运行" })
		return
	end

	sys.call("rm -f /tmp/radar-raw1-update.log /tmp/radar-raw1-update.status /tmp/radar-raw1-update.total")
	sys.call("(/usr/bin/radar-raw1-update > /tmp/radar-raw1-update.log 2>&1 </dev/null) &")
	write_json({ ok = true })
end

function action_update_status()
	local sys = require "luci.sys"
	local state, percent, message = "idle", 0, "等待更新"
	local status = io.open("/tmp/radar-raw1-update.status", "r")
	if status then
		state = status:read("*l") or state
		percent = tonumber(status:read("*l")) or percent
		message = status:read("*l") or message
		status:close()
	end

	local downloaded, total = 0, 0
	if state == "downloading" then
		downloaded = tonumber(sys.exec("wc -c < /tmp/radar-update/radar-raw1-sender.new 2>/dev/null")) or 0
		total = tonumber(sys.exec("cat /tmp/radar-raw1-update.total 2>/dev/null")) or 0
		if total > 0 then
			percent = math.min(85, 15 + math.floor(downloaded * 70 / total))
		end
	end

	local log = ""
	if state == "failed" or state == "done" then
		log = sys.exec("tail -n 12 /tmp/radar-raw1-update.log 2>/dev/null")
	end
	write_json({
		state = state,
		percent = percent,
		message = message,
		downloaded = downloaded,
		total = total,
		log = log
	})
end
