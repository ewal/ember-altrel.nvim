local M = {}

local rotation_segments = {
  controllers = 'templates',
  templates = 'routes',
  routes = 'controllers',
}

local rotation_extensions = {
  controllers = '.hbs',
  templates = '.ts',
  routes = '.ts',
}

---@param list string[]
local function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

---@param file string
local function file_exists(file)
  return vim.fn.filereadable(file) == 1
end


---@param file string
local function file_extension(file)
  local index = file:find('.', 1, true)
  return file:sub(index + 1)
end

---@param file string
local function file_without_extension(file)
  local index = file:find('.', 1, true)
  return file:sub(1, index - 1)
end

---@param file string
local function open_file(file)
  if not file_exists(file) then
    print('File not found: ' .. file)
  else
    vim.cmd.edit(file)
  end
end

---@param file string
local function fallback_to_js(file)
  if file_exists(file) then
    return file
  elseif file_extension(file) == 'ts' then
    return file_without_extension(file) .. '.js'
  else
    return file
  end
end

local function rotate_next()
  local file_path = vim.fn.expand('%')
  local segments = Set(vim.split(file_path, '/'))

  if file_path == '' then
    print('No file buffer open')
  else
    for key, val in pairs(rotation_segments) do
      if segments[key] then
        local next_path = string.gsub(file_path, key, val)
        next_path = file_without_extension(next_path) .. rotation_extensions[key]
        open_file(fallback_to_js(next_path))
        break
      end
    end
  end
end

---@param opts table
function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command('EmberRelNext', rotate_next, {})
end

return M
