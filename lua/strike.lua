-- 1) Define the highlight group once (init.lua)
vim.api.nvim_set_hl(0, "Strike", { strikethrough = true })

-- 2) Minimal toggler using vim.hl.range
local M = {}
local ns = vim.api.nvim_create_namespace "strike_selection"

function M.toggle_visual_strike()
  local bufnr = 0

  -- Visual selection marks (1-based)
  local s_row, s_col = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
  local e_row, e_col = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))

  -- Normalize order (user might select backwards)
  if (e_row < s_row) or (e_row == s_row and e_col < s_col) then
    s_row, e_row, s_col, e_col = e_row, s_row, e_col, s_col
  end

  -- Convert to 0-based; make end exclusive for vim.hl.range
  s_row, s_col = s_row - 1, math.max(0, s_col - 1)
  e_row, e_col = e_row - 1, e_col -- end is exclusive; no -1 here

  -- If anything already highlighted in the span, clear = toggle off
  local has = #vim.api.nvim_buf_get_extmarks(bufnr, ns, { s_row, 0 }, { e_row, -1 }, {}) > 0
  if has then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, s_row, e_row + 1)
    return
  end

  -- Apply strikethrough in one call
  vim.hl.range(bufnr, ns, "Strike", { s_row, s_col }, { e_row, e_col }, { inclusive = false })
end

function M.toggle_visual_strike_mode_aware()
  local bufnr = 0

  -- 1) Build a region from Visual selection that accounts for the mode
  local vmode = vim.fn.visualmode() -- "v", "V", or "\022" (block)
  local s_row, s_col = unpack(vim.api.nvim_buf_get_mark(bufnr, "<")) -- 1-based
  local e_row, e_col = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))

  -- Normalize order
  if (e_row < s_row) or (e_row == s_row and e_col < s_col) then
    s_row, e_row, s_col, e_col = e_row, s_row, e_col, s_col
  end

  -- Region API takes 1-based {line, col}; returns per-line [start_col, end_col_excl]
  local region = vim.region(bufnr, { s_row, s_col }, { e_row, e_col }, vmode, true)

  -- 2) Toggle logic: if any extmark in span, clear; else paint each line
  local has = #vim.api.nvim_buf_get_extmarks(bufnr, ns, { s_row - 1, 0 }, { e_row - 1, -1 }, {}) > 0
  if has then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, s_row - 1, e_row) -- end is exclusive
    return
  end

  -- 3) Apply highlight line-by-line
  for lnum, cols in pairs(region) do
    local start_col_0 = math.max(0, cols[1] - 1) -- to 0-based
    local end_col_0 = cols[2] -- already exclusive once 0-based
    vim.hl.range(bufnr, ns, "Strike", { lnum - 1, start_col_0 }, { lnum - 1, end_col_0 }, { inclusive = false })
  end
end

return M
