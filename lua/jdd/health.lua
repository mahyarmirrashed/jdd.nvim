local health = vim.health or require("health")
local M = {}

--- Runs health checks for jdd.nvim.
-- Checks if plenary.nvim is installed and if the `jdd` binary is available in $PATH.
-- This function is called automatically by Neovim's :checkhealth command.
function M.check()
  health.start("jdd.nvim")

  -- Check if plenary.nvim is available
  local ok, _ = pcall(require, "plenary.job")
  if not ok then
    health.error("plenary.nvim is not installed or not found in runtimepath.")
    return
  else
    health.ok("plenary.nvim is installed.")
  end

  -- Check if jdd is in PATH
  local jdd_path = vim.fn.exepath("jdd")
  if jdd_path and jdd_path ~= "" then
    health.ok("jdd binary found: " .. jdd_path)
  else
    health.error("jdd binary not found in $PATH. Please install jdd and ensure it is available in your PATH.")
  end
end

return M
