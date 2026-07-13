-- render-markdown.nvim, brought in via
-- `{ import = "astrocommunity.markdown-and-latex.render-markdown-nvim" }`
-- (see community.lua). This spec only *extends* that module's defaults to port
-- the two custom checkbox states we used to define under obsidian.nvim's
-- `ui.checkboxes`. Everything else (unchecked `[ ]`, checked `[x]`, headings,
-- code blocks, conceallevel handling, …) keeps render-markdown's stock behaviour.
--
-- render-markdown is render-only: unlike obsidian.nvim it does NOT toggle
-- checkboxes or manage daily notes / templates / links. That was an intentional
-- trade when replacing obsidian.nvim.
return {
  "MeanderingProgrammer/render-markdown.nvim",

  -- Define the highlight groups our custom checkboxes reference. Done in `init`
  -- (runs at startup, independent of when the plugin lazy-loads) and re-applied
  -- on every ColorScheme change so the colours survive theme reloads.
  init = function()
    local function set_hl()
      -- Ported verbatim from the old `ObsidianPending` highlight.
      vim.api.nvim_set_hl(0, "RenderMarkdownInProgress", { bold = true, fg = "#ffcb6b" })
      -- Deferred / forwarded task: muted blue.
      vim.api.nvim_set_hl(0, "RenderMarkdownDeferred", { fg = "#82aaff" })
    end
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
    set_hl()
  end,

  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = function(_, opts)
    return require("astrocore").extend_tbl(opts, {
      -- Deep-merges with render-markdown's default `checkbox` table, so the stock
      -- `unchecked` / `checked` icons and the built-in `todo` (`[-]`) custom state
      -- are all preserved; we only add these two.
      checkbox = {
        custom = {
          -- In-progress task, ported from obsidian's custom `.` state.
          in_progress = { raw = "[.]", rendered = "󰔟 ", highlight = "RenderMarkdownInProgress" },
          -- Deferred / forwarded task, ported from obsidian's `>` state.
          deferred = { raw = "[>]", rendered = " ", highlight = "RenderMarkdownDeferred" },
        },
      },
    })
  end,
}
