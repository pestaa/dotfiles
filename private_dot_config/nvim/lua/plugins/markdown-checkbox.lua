-- Ports the one bit of obsidian.nvim behaviour we still want after switching to
-- render-markdown.nvim: pressing <CR> on a task line cycles its checkbox state
-- (obsidian bound this to `smart_action`). render-markdown only *renders*
-- checkboxes, so the mutation logic lives here.
--
-- Config-only spec: it piggybacks on AstroCore (always loaded) solely to
-- register a FileType autocmd, mirroring how the rest of this config extends
-- AstroCore. No new plugin is installed.

-- States <CR> rotates through, in order. Follows obsidian's original
-- `checkbox.order` philosophy (empty -> done first, then in-progress) but is
-- limited to the states render-markdown is configured to render:
-- unchecked " ", checked "x", in-progress ".", deferred ">". Reorder/extend to
-- taste (add "~"/"!" here only if you also define them in render-markdown.lua).
local CYCLE = { " ", "x", ".", ">" }

local function next_state(state)
  for i, s in ipairs(CYCLE) do
    if s == state then return CYCLE[i % #CYCLE + 1] end
  end
  return CYCLE[1] -- unknown state (e.g. a stray "[~]") -> reset to the first
end

-- <CR> handler, buffer-local to markdown. Mirrors obsidian's smart_action:
--   * on an existing checkbox -> cycle its state
--   * on a plain list item    -> turn it into a task ("- [ ]")
--   * anywhere else           -> fall through to the default normal-mode <CR>
local function checkbox_cr()
  local line = vim.api.nvim_get_current_line()

  local indent, marker, state, rest = line:match "^(%s*)([-*+]%s+)%[(.)%]%s?(.*)$"
  if state then
    local text = rest ~= "" and (" " .. rest) or ""
    vim.api.nvim_set_current_line(("%s%s[%s]%s"):format(indent, marker, next_state(state), text))
    return
  end

  local li_indent, li_marker, li_rest = line:match "^(%s*)([-*+]%s+)(.*)$"
  if li_marker then
    local text = li_rest ~= "" and (" " .. li_rest) or ""
    vim.api.nvim_set_current_line(("%s%s[ ]%s"):format(li_indent, li_marker, text))
    return
  end

  -- Not a task/list line: behave like a plain normal-mode <CR>.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = function(_, opts)
    local autocmds = opts.autocmds or {}
    autocmds.markdown_checkbox = {
      {
        event = "FileType",
        pattern = "markdown",
        desc = "Toggle task checkbox on <CR> (mirrors obsidian.nvim smart_action)",
        callback = function(args)
          vim.keymap.set("n", "<CR>", checkbox_cr, {
            buffer = args.buf,
            desc = "Cycle task checkbox state",
          })
        end,
      },
    }
    opts.autocmds = autocmds
    return opts
  end,
}
