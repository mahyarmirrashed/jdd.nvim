local M = {}
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
-- @field autostart? boolean Whether to auto-start JDD on setup (default: true)
M.config = {
  root = nil,
  log_level = nil,
  dry_run = false,
  exclude = nil,
  config = nil,
  autostart = true,
}

local jdd_handle = nil

--- Sets up the jdd.nvim plugin.
-- Call this before using other functions.
-- @param opts table|nil Table of options (see M.config fields)
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  if M.config.autostart then M.start() end
end

--- Starts the Johnny Decimal Daemon process in the foreground.
-- Passes all configured options as CLI arguments.
function M.start()
  -- If already running, stop first
  if jdd_handle then
    log.info("stopping running jdd before starting a new one")

    M.stop()

    -- Wait for previous job to exit before starting a new one
    vim.wait(1000, function() return jdd_handle == nil end, 10, false)
  end

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

  jdd_handle = vim.system(vim.list_extend({ "jdd" }, args), {
    stdout = function(_, data)
      if data then log.info(data) end
    end,
    stderr = function(_, data)
      if data then log.error(data) end
    end,
    detach = false,
  }, function(obj)
    log.info("jdd exited with code " .. tostring(obj.code))
    jdd_handle = nil
    log.info("jdd handle reference cleared after exit")
  end)

  log.info("jdd job started (pid: " .. tostring(jdd_handle.pid) .. ")")
end

--- Stops the running Johnny Decimal Daemon process, if any.
function M.stop()
  if jdd_handle and jdd_handle.pid then
    log.info("requesting shutdown of jdd (pid: " .. tostring(jdd_handle.pid) .. ")")
    vim.loop.kill(jdd_handle.pid, 15) -- 15 = SIGTERM
  else
    log.info("no jdd job to stop")
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

vim.api.nvim_create_user_command(
  "JddStatus",
  function() vim.notify("jdd running: " .. tostring(jdd_handle ~= nil and jdd_handle.pid ~= nil)) end,
  { desc = "Indicates if the Johnny Decimal Daemon (jdd) is currently running." }
)

return M
