#!/usr/bin/env lua

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

---@param file string
local function fallback_to_gts(file)
	if file_exists(file) then
		return file
	elseif file_extension(file) == "hbs" then
		return file_without_extension(file) .. ".gts"
	else
		return file
	end
end

---@param t table
local function reverse_table(t)
	local reversed = {}
	for k, v in pairs(t) do
		reversed[v] = k
	end
	return reversed
end

---@param current_file string
local function rotate_component(current_file)
	local ext = file_extension(current_file)
	if ext == "hbs" or ext == "gts" then
		open_file(fallback_to_js(file_without_extension(current_file) .. ".ts"))
	else
		open_file(fallback_to_gts(file_without_extension(current_file) .. ".hbs"))
	end
end

local function rotate(dir)
	local file_path = vim.fn.expand("%")

	if file_path == "" then
		return print("No file buffer open")
	end

	local ext = dir == "backward" and swapped_rotation_extensions or rotation_extensions
	local rot = dir == "backward" and reverse_table(rotation_segments) or rotation_segments
	local current_path = file_path

	for _ = 1, 3 do
		local segments = Set(vim.split(current_path, "/"))
		local next_path = nil
		local is_component = false

		for key, val in pairs(rot) do
			if segments[key] then
				if key == "components" then
					is_component = true
					next_path = current_path
				else
					next_path = string.gsub(current_path, key, val)
					next_path = file_without_extension(next_path) .. ext[key]
					next_path = fallback_to_gts(fallback_to_js(next_path))
				end
				break
			end
		end

		if next_path == nil then
			break
		end

		if is_component then
			rotate_component(next_path)
			return
		end

		if file_exists(next_path) then
			vim.cmd.edit(next_path)
			return
		end

		current_path = next_path
	end

	print("No related file found")
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
