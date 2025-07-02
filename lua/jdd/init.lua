local M = {}
local Job = require("plenary.job")
local log = require("plenary.log").new({
  plugin = "jdd",
  level = "info",
  use_console = false,
})

--- Default configuration for jdd.nvim
-- @field root? string Directory to watch
-- @field log_level? string Logging level: debug, info, warn, error
-- @field dry_run? boolean If true, don't move files
-- @field exclude? table|string Glob patterns to exclude
-- @field config? string Path to config file
-- @field start? boolean Whether to auto-start JDD on setup (default: true)
M.config = {
  root = nil,
  log_level = nil,
  dry_run = false,
  exclude = nil,
  config = nil,
  start = true,
}

local jdd_job = nil

--- Sets up the jdd.nvim plugin.
-- Call this before using other functions.
-- @param opts table|nil Table of options (see M.config fields)
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  if M.config.start then M.start() end
end

--- Starts the Johnny Decimal Daemon process in the foreground.
-- Passes all configured options as CLI arguments.
function M.start()
  -- If already running, stop first
  if jdd_job then M.stop() end

  local args = {}

  if M.config.config then
    table.insert(args, "--config")
    table.insert(args, M.config.config)
  end
  if M.config.root then
    table.insert(args, "--root")
    table.insert(args, M.config.root)
  end
  if M.config.log_level then
    table.insert(args, "--log-level")
    table.insert(args, M.config.log_level)
  end
  if M.config.dry_run then table.insert(args, "--dry-run") end
  if M.config.exclude then
    if type(M.config.exclude) == "table" then
      for _, ex in ipairs(M.config.exclude) do
        table.insert(args, "--exclude")
        table.insert(args, ex)
      end
    else
      table.insert(args, "--exclude")
      table.insert(args, M.config.exclude)
    end
  end

  jdd_job = Job:new({
    command = "jdd",
    args = args,
    on_stdout = function(_, data)
      vim.schedule(function() log.info(data) end)
    end,
    on_stderr = function(_, data)
      vim.schedule(function() log.error(data) end)
    end,
    on_exit = function(_, code)
      vim.schedule(function() log.info("jdd exited with code " .. tostring(code)) end)
    end,
  })

  jdd_job:start()
end

--- Stops the running Johnny Decimal Daemon process, if any.
function M.stop()
  if jdd_job then
    jdd_job:shutdown()
    jdd_job = nil
  end
end

--- Ensures the Johnny Decimal Daemon is stopped when Neovim exits.
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function() M.stop() end,
})

--- Create auto commands for starting and stopping the Johnny Decimal Daemon.
vim.api.nvim_create_user_command(
  "JddStart",
  function() M.start() end,
  { desc = "Start the Johnny Decimal Daemon (jdd) if it is not already running." }
)

vim.api.nvim_create_user_command(
  "JddStop",
  function() M.stop() end,
  { desc = "Stop the Johnny Decimal Daemon (jdd) if it is currently running." }
)

return M
