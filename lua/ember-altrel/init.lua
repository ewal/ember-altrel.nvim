local M = {}

local rotation_segments = {
	controllers = "templates",
	templates = "routes",
	routes = "controllers",
	components = "components",
}

local rotation_extensions = {
	controllers = ".hbs",
	templates = ".ts",
	routes = ".ts",
}

local swapped_rotation_extensions = {
	controllers = ".ts",
	templates = ".ts",
	routes = ".hbs",
}

---@param list string[]
---@return table<string, true>
local function Set(list)
	local set = {}
	for _, l in ipairs(list) do
		set[l] = true
	end
	return set
end

---@param file string
local function file_exists(file)
	return vim.fn.filereadable(file) == 1
end

---@param file string
local function file_extension(file)
	local index = file:find(".", 1, true)
	return file:sub(index + 1)
end

---@param file string
local function file_without_extension(file)
	local index = file:find(".", 1, true)
	return file:sub(1, index - 1)
end

---@param file string
local function open_file(file)
	if not file_exists(file) then
		print("File not found: " .. file)
	else
		vim.cmd.edit(file)
	end
end

---@param file string
local function fallback_to_js(file)
	if file_exists(file) then
		return file
	elseif file_extension(file) == "ts" then
		return file_without_extension(file) .. ".js"
	else
		return file
	end
end

local function reverse_table(t)
	local reversed = {}
	for k, v in pairs(t) do
		reversed[v] = k
	end
	return reversed
end

local function rotate(dir)
	local file_path = vim.fn.expand("%")
	local segments = Set(vim.split(file_path, "/"))

	local ext = dir == "backward" and swapped_rotation_extensions or rotation_extensions
	local rot = dir == "backward" and reverse_table(rotation_segments) or rotation_segments

	if file_path == "" then
		print("No file buffer open")
	else
		for key, val in pairs(rot) do
			if segments[key] then
				if key == "components" then
					local current_file = string.gsub(file_path, key, val)
					if file_extension(current_file) == "hbs" then
						open_file(fallback_to_js(file_without_extension(current_file) .. ".ts"))
					else
						open_file(file_without_extension(current_file) .. ".hbs")
					end
					break
				else
					local next_path = string.gsub(file_path, key, val)
					next_path = file_without_extension(next_path) .. ext[key]
					open_file(fallback_to_js(next_path))
					break
				end
			end
		end
	end
end

function M.rotate_next()
	rotate()
end

function M.rotate_prev()
	rotate("backward")
end

---@param opts table
function M.setup(opts)
	opts = opts or {}
end

return M
