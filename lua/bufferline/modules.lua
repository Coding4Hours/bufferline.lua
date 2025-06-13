local api = vim.api
local fn = vim.fn
local utils = require("bufferline.utils")
local mini_icons_present, mini_icons = pcall(require, "mini.icons")
utils.btns()

local M = {}

M.CoverNvimTree = function()
	return "%#NvimTreeNormal#" .. (vim.g.nvimtree_side == "right" and "" or string.rep(" ", utils.getNvimTreeWidth()))
end

M.bufferlist = function()
	local buffers = {} -- buffersults
	local available_space = vim.o.columns - utils.getNvimTreeWidth() - utils.getBtnsWidth()
	local current_buf = api.nvim_get_current_buf()
	local has_current = false -- have we seen current buffer yet?

	for _, bufnr in ipairs(vim.t.bufs) do
		if utils.isBufValid(bufnr) then
			if ((#buffers + 1) * 21) > available_space then
				if has_current then
					break
				end

				table.remove(buffers, 1)
			end

			has_current = (bufnr == current_buf and true) or has_current
			table.insert(buffers, utils.styleBufferTab(bufnr))
		end
	end

	vim.g.visibuffers = buffers
	return table.concat(buffers) .. "%#TblineFill#" .. "%=" -- buffers + empty space
end

vim.g.TbTabsToggled = 0

M.tablist = function()
	local result, number_of_tabs = "", fn.tabpagenr("$")

	if number_of_tabs > 1 then
		local tab_close_icon = mini_icons_present and mini_icons.get_icon_by_name("close") or "󰅙"
		local tab_add_icon = mini_icons_present and mini_icons.get_icon_by_name("plus") or ""
		local tab_icon = mini_icons_present and mini_icons.get_icon_by_name("folder") or "󰌒"
		local tab_toggle_icon = mini_icons_present and mini_icons.get_icon_by_name("chevron_left") or ""

		for i = 1, number_of_tabs, 1 do
			local tab_hl = ((i == fn.tabpagenr()) and "%#TbLineTabOn# ") or "%#TbLineTabOff# "
			result = result .. ("%" .. i .. "@TbGotoTab@" .. tab_hl .. i .. " ")
			result = (
				i == fn.tabpagenr()
				and result .. "%#TbLineTabCloseBtn#" .. "%@TbTabClose@" .. tab_close_icon .. " %X"
			) or result
		end

		local new_tabtn = "%#TblineTabNewBtn#" .. "%@TbNewTab@ " .. tab_add_icon .. "%X"
		local tabstoggleBtn = "%@TbToggleTabs@ %#TBTabTitle# " .. tab_icon .. " %X"

		return vim.g.TbTabsToggled == 1 and tabstoggleBtn:gsub("()", { [36] = tab_toggle_icon .. " " })
			or new_tabtn .. tabstoggleBtn .. result
	end
end

M.buttons = function()
	local close_all_icon = mini_icons_present and mini_icons.get_icon_by_name("close") or "󰅖"
	local CloseAllBufsBtn = "%@TbCloseAllBufs@%#TbLineCloseAllBufsBtn# " .. close_all_icon .. " %X"
	return CloseAllBufsBtn
end

return M
