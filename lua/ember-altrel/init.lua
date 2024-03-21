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

function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function Open_file(file)
  if not File_exists(file) then
    print('File not found: ' .. file)
  else
    vim.cmd.edit(file)
  end
end

function Fallback_to_js(file)
  if not File_exists(file) and File_extension(file) == 'ts' then
    return file:gsub("%.ts", "") .. '.js'
  else
    return file
  end
end

function File_extension(file)
  return string.match(file, "^.+%.(.+)$")
end

function File_exists(file)
  return vim.fn.filereadable(file) == 1
end

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command('EmberRelNext', function()
    local file_path = vim.fn.expand('%')
    local segments = Set(vim.split(file_path, '/'))

    if file_path == '' then
      print('No file buffer open')
    else
      for key, val in pairs(rotation_segments) do
        if segments[key] then
          local next_path = string.gsub(file_path, key, val)
          next_path = string.gsub(next_path, '.' .. File_extension(file_path), rotation_extensions[key])
          Open_file(Fallback_to_js(next_path))
          break
        end
      end
    end
  end, {})
end

return M
