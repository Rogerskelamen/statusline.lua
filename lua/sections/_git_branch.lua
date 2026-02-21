local utils = require("modules.utils")

local M = {}

local uv = vim.uv or vim.loop

-- repo cache
-- [root] = {
--   branch = "main",
--   watcher = uv_fs_event,
-- }
local repos = {}
local icon = ""
local space = " "

---Return root dir of '.git'
---@param path? string
---@return string|nil
local function get_git_root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  local dir = vim.fs.dirname(path)
  local git_dir = vim.fs.find(".git", {
    upward = true,
    path = dir,
  })[1]

  if not git_dir then
    return nil
  end

  return vim.fs.dirname(git_dir)
end

---Get branch name of current project
---@param root string
local function fetch_branch(root)
  vim.system({ "git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }, function(obj)
    if obj.code ~= 0 then
      return
    end

    local branch = vim.trim(obj.stdout)

    if branch == "HEAD" then
      -- detached HEAD fallback
      vim.system({ "git", "-C", root, "rev-parse", "--short", "HEAD" }, { text = true }, function(detached)
        if detached.code == 0 then
          repos[root].branch = vim.trim(detached.stdout)
        end
      end)
    else
      repos[root].branch = branch
    end
  end)
end

---Return 'HEAD' file path
---@param root string
---@return string|nil
local function get_head_path(root)
  local dotgit = root .. "/.git"

  local stat = uv.fs_stat(dotgit)
  if not stat then
    return nil
  end
  if stat.type == "directory" then
    return dotgit .. "/HEAD"
  end

  -- submodule or worktree (.git is file)
  local f = io.open(dotgit)
  if not f then
    return nil
  end

  local content = f:read("*l")
  f:close()

  local gitdir = content:match("gitdir: (.+)")
  if not gitdir then
    return nil
  end

  if not gitdir:match("^%a:[/\\]") then
    gitdir = root .. "/" .. gitdir
  end

  return gitdir .. "/HEAD"
end

---Store repo watch to root table
---@param root string
local function watch_repo(root)
  if repos[root] and repos[root].watcher then
    return
  end

  repos[root] = repos[root] or {}

  local function start_watcher()
    local head_path = get_head_path(root)
    if not head_path then
      return
    end

    local watcher = uv.new_fs_event()

    watcher:start(head_path, {}, function()
      -- stop and recreate watcher
      watcher:stop()
      watcher:close()

      repos[root].watcher = nil
      fetch_branch(root)

      -- restart watcher
      vim.schedule(function()
        watch_repo(root)
      end)
    end)

    repos[root].watcher = watcher
  end

  start_watcher()

  -- initial fetch
  fetch_branch(root)
end

function M.branch()
  if not utils.has_version(0, 10) then
    return ""
  end

  local root = get_git_root()
  if not root then
    return ""
  end

  if not repos[root] then
    watch_repo(root)
  end

  local branch = repos[root].branch
  if not branch or branch == "" then
    return ""
  end

  return icon .. space .. branch
end

return M

---ARCHIVE --> A lot shorter but has async issues
--function M.getGitBranch() --> NOTE: THIS FN HAS AN ASYNC ISSUE AND NEEDS TO BE DEALT WITH LATER
--local branch = vim.fn.systemlist('cd ' .. vim.fn.expand('%:p:h:S') .. ' 2>/dev/null && git status --porcelain -b 2>/dev/null')[1]
--local branch = vim.fn.systemlist('cd ' .. vim.fn.expand('%:p:h:S') .. ' 2>/dev/null && git rev-parse --abbrev-ref HEAD')[1] --> Same async issue
--local data = vim.b.git_branch
--if not branch or #branch == 0 then
-- return ''
--end
--branch = branch:gsub([[^## No commits yet on (%w+)$]], '%1')
--branch = branch:gsub([[^##%s+(%w+).*$]], '%1')
--return branch
--end
