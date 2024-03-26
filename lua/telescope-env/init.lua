local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values

local function file_exists(file)
  if vim.fn.filereadable(file) ~= 1 then return nil end
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function lines_from(file)
  if not file_exists(file) then return nil end
  local lines = {}
  for line in io.lines(file) do
    if line ~= '' and string.sub(line, 1, 1) ~= '#' then
      lines[#lines + 1] = line
    end
  end
  return lines
end

local M = {}
-- our picker function: colors
function M.env_values(opts)
  local cwd = vim.fn.getcwd(0)
  local env_file = cwd .. '/.env'
  local lines = lines_from(env_file)
  if lines == nil then
    vim.notify('.env file not found', 3)
    return
  end

  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Environment Variables",
    theme = 'dropdown',
    finder = finders.new_table({
      results = lines,
      entry_maker = function(entry)
        local key = string.match(entry, '([A-Z0-9_]*)=.*')
        local value = string.match(entry, '[A-Z0-9_]*=(.*)')
        return {
          value = value,
          display = key,
          ordinal = key,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<C-k>', function ()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.fn.setreg('+', selection.ordinal)
      end)
      map('i', '<C-v>', function ()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.fn.setreg('+', selection.value)
      end)
      map('i', '<C-n>', function ()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.notify(selection.value)
      end)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd('find +/' .. selection.ordinal .. '= .env')
      end)
      return true
    end,
  }):find()
end

-- to execute the function
-- env_values(require('telescope.themes').get_dropdown({}))

return M
