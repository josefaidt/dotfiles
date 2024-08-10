-- ~/.config/nvim/lua/fold_filters.lua

local vscode = require('vscode-neovim')
local M = {}

-- Function to set the current filter
function M.SetFilter(new_filter)
  vim.g.vscode_amplify_docs_current_filter = new_filter
  -- print("Filter set to: " .. new_filter)
end

-- Function to fold regions where the filter is not the specified filter
function M.FoldNonMatchingFilters()
  local current_filter = vim.g.vscode_amplify_docs_current_filter
  if not current_filter then
    -- print("No filter set.")
    return
  end

  local start_pattern = '<InlineFilter filters={'
  local end_pattern = '</InlineFilter>'
  local markers = {}
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local fold_start = nil

  for i, line in ipairs(lines) do
    if string.find(line, start_pattern) then
      local filters = string.match(line, 'filters={%[(.-)%]}')
      if filters then
        local filter_list = {}
        for filter in string.gmatch(filters, '"(.-)"') do
          table.insert(filter_list, filter)
        end
        local match_found = false
        for _, filter in ipairs(filter_list) do
          if filter == current_filter then
            match_found = true
            break
          end
        end
        if not match_found then
          fold_start = i - 1 -- Adjust for zero-based indexing
        end
      end
    elseif string.find(line, end_pattern) then
      if fold_start then
        local fold_end = i - 1 -- Adjust for zero-based indexing
        table.insert(markers, { fold_start, fold_end })
        fold_start = nil
      end
    end
  end

  -- Use VSCode commands to fold regions
  for _, range in ipairs(markers) do
    -- print(string.format("Folding range: %d-%d", range[1], range[2]))
    vscode.call('editor.fold', { range = { range[1], range[2] } })
  end

  -- Restore cursor position and bring it into view
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.cmd('normal zz')
end

return M
