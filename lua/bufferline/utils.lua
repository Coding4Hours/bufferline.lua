local M = {}
local api = vim.api
local fn = vim.fn
local show_numbers = require("bufferline").show_numbers
local kind_icons = require("bufferline").kind_icons
local mini_icons_present, mini_icons = pcall(require, "mini.icons")

function M.isBufValid(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

function M.bufilter()
	local bufs = vim.t.bufs or nil
	if not bufs then
		return {}
	end
	for i = #bufs, 1, -1 do
		if not api.nvim_buf_is_valid(bufs[i]) and vim.bo[bufs[i]].buflisted then
			table.remove(bufs, i)
		end
	end
	return bufs
end

function M.getBufIndex(bufnr)
	for i, value in ipairs(vim.t.bufs) do
		if value == bufnr then
			return i
		end
	end
end

function M.getNvimTreeWidth()
	for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
		if vim.bo[api.nvim_win_get_buf(win)].ft == "NvimTree" then
			return api.nvim_win_get_width(win) + 1
		end
	end
	return 0
end

function M.new_hl(group1, group2)
	local fg = fn.synIDattr(fn.synIDtrans(fn.hlID(group1)), "fg#")
	local bg = fn.synIDattr(fn.synIDtrans(fn.hlID(group2)), "bg#")
	api.nvim_set_hl(0, "Tbline" .. group1 .. group2, { fg = fg, bg = bg })
	return "%#" .. "Tbline" .. group1 .. group2 .. "#"
end

function M.add_fileInfo(name, bufnr)
	local icon = ""
	local icon_hl = "DevIconDefault" -- Default highlight, can be adjusted

	if mini_icons_present then
		local filetype = vim.bo[bufnr].filetype
		icon = mini_icons.get_icon_for_filetype(filetype, name) -- Pass name as fallback
	else
		-- Fallback if mini.icons is not available (optional)
		icon = "󰈚" -- Use a default unknown file icon if mini.icons is not present
	end

	-- Apply highlight to the icon
	icon = (
		api.nvim_get_current_buf() == bufnr and M.new_hl(icon_hl, "TbLineBufOn") .. " " .. icon
		or M.new_hl(icon_hl, "TbLineBufOff") .. " " .. icon
	)

	-- Logic for handling duplicate names (remains the same)
	for _, value in ipairs(vim.t.bufs) do
		if M.isBufValid(value) then
			if name == fn.fnamemodify(api.nvim_buf_get_name(value), ":t") and value ~= bufnr then
				local other = {}
				for match in (vim.fs.normalize(api.nvim_buf_get_name(value)) .. "/"):gmatch("(.-)" .. "/") do
					table.insert(other, match)
				end
				local current = {}
				for match in (vim.fs.normalize(api.nvim_buf_get_name(bufnr)) .. "/"):gmatch("(.-)" .. "/") do
					table.insert(current, match)
				end
				name = current[#current]
				for i = #current - 1, 1, -1 do
					local value_current = current[i]
					local other_current = other[i]
					if value_current ~= other_current then
						if (#current - i) < 2 then
							name = value_current .. "/" .. name
						else
							name = value_current .. "/../" .. name
						end
						break
					end
				end
				break
			end
		end
	end

	local padding = (24 - #name - 5) / 2
	local maxname_len = 16
	name = (#name > maxname_len and string.sub(name, 1, 14) .. "..") or name
	name = (api.nvim_get_current_buf() == bufnr and "%#TbLineBufOn# " .. name) or ("%#TbLineBufOff# " .. name)

	if kind_icons then
		return string.rep(" ", padding) .. icon .. name .. string.rep(" ", padding)
	else
		return string.rep(" ", padding) .. name .. string.rep(" ", padding)
	end
end

function M.getBtnsWidth()
	local width = 6
	if fn.tabpagenr("$") ~= 1 then
		width = width + ((3 * fn.tabpagenr("$")) + 2) + 10
		width = not vim.g.TbTabsToggled and 8 or width
	end
	return width
end

function M.styleBufferTab(nr)
	local close_icon = mini_icons_present and mini_icons.get_icon_by_name("close") or "󰅖"
	local modified_icon = mini_icons_present and mini_icons.get_icon_by_name("circle_filled") or ""

	local close_btn = "%" .. nr .. "@TbKillBuf@ " .. close_icon .. " %X"
	local name = (#api.nvim_buf_get_name(nr) ~= 0) and fn.fnamemodify(api.nvim_buf_get_name(nr), ":t") or " No Name "
	name = "%" .. nr .. "@TbGoToBuf@" .. M.add_fileInfo(name, nr) .. "%X"
	if show_numbers then
		for index, value in ipairs(vim.t.bufs) do
			if nr == value then
				name = " " .. index .. name
				break
			end
		end
	end
	if nr == api.nvim_get_current_buf() then
		close_btn = (vim.bo[0].modified and "%" .. nr .. "@TbKillBuf@%#TbLineBufOnModified# " .. modified_icon .. " ")
			or ("%#TbLineBufOnClose#" .. close_btn)
		name = "%#TbLineBufOn#" .. name .. close_btn
	else
		close_btn = (vim.bo[nr].modified and "%" .. nr .. "@TbKillBuf@%#TbBufLineBufOffModified# " .. modified_icon .. " ")
			or ("%#TbLineBufOffClose#" .. close_btn)
		name = "%#TbLineBufOff#" .. name .. close_btn
	end

	return name
end

function M.btns()
	vim.cmd("function! TbGoToBuf(bufnr,b,c,d) \n execute 'b'..a:bufnr \n endfunction")

	vim.cmd([[
   function! TbKillBuf(bufnr,b,c,d)
        call luaeval('require("bufferline.functions").closebuffer(_A)', a:bufnr)
  endfunction]])

	vim.cmd("function! TbNewTab(a,b,c,d) \n tabnew \n endfunction")
	vim.cmd("function! TbGotoTab(tabnr,b,c,d) \n execute a:tabnr ..'tabnext' \n endfunction")
	vim.cmd(
		"function! TbTabClose(a,b,c,d) \n lua require('bufferline.functions').closeAllBufs('closeTab') \n endfunction"
	)
	vim.cmd("function! TbCloseAllBufs(a,b,c,d) \n lua require('bufferline.functions').closeAllBufs() \n endfunction")
	vim.cmd("function! TbToggleTabs(a,b,c,d) \n let g:TbTabsToggled = !g:TbTabsToggled | redrawtabline \n endfunction")
end

return M
