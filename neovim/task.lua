-- tasks.lua
local M = {}

-- Create a simple debug utility
M.debug = {
	enabled = false,

	-- Use print instead of vim.notify for reliable message logging
	log = function(message)
		if M.debug.enabled then
			print("DEBUG: " .. message)
		end
	end
}

-- Function to toggle debug mode
function M.toggle_debug()
	M.debug.enabled = not M.debug.enabled
	-- Use print here too for consistency
	print("Task plugin debug mode: " .. (M.debug.enabled and "enabled" or "disabled"))
end

function M.setup(opts)
	-- Get options with defaults
	opts = opts or {}
	M.debug.enabled = opts.debug or false

	local function toggle_task()
		-- Get the current line
		local line = vim.api.nvim_get_current_line()
		M.debug.log("Current line: " .. line)

		-- Check if the line contains a markdown task
		local task_pattern = "%[[ x]%]"
		local has_task = line:match(task_pattern)
		M.debug.log("Contains task?: " .. tostring(has_task ~= nil))

		if has_task then
			local original_line = line

			if line:match("%[ %]") then
				local date = os.date("%m-%d %H:%M")
				line = line:gsub("%[ %]", "[x]")
				line = line:gsub(" %(%d%d%-%d%d %d%d?:%d%d%)", "") -- Remove any existing date
				line = line .. " (" .. date .. ")"
			else
				line = line:gsub("%[x%]", "[ ]")
				line = line:gsub(" %(%d%d%-%d%d %d%d?:%d%d%)", "")
			end

			M.debug.log("Line transformed from: '" .. original_line .. "' to: '" .. line .. "'")
			vim.api.nvim_set_current_line(line)
		else
			M.debug.log("No task found on current line")
		end
	end

	-- Create the keymap
	vim.keymap.set('n', '<leader>x', toggle_task, {
		noremap = true,
		silent = true, -- Even with silent=true, print() messages will show in :messages
		desc = "Toggle task completion with timestamp"
	})

	-- Create command for toggling debug mode
	vim.api.nvim_create_user_command('TaskToggleDebug', M.toggle_debug, {
		desc = "Toggle debug mode for task plugin"
	})

	M.debug.log("Task toggle feature initialized!")
end

return M

