-- The github_* colorschemes set `background` themselves, so the hooks only need
-- to switch the colorscheme. Setting `background` first makes Neovim reload the
-- *outgoing* colorscheme (`:h 'background'`), and that reload clears
-- `g:colors_name`, so any hiccup between the two statements strands the UI on
-- Neovim's `default` scheme.
local themes = { dark = "github_dark_high_contrast", light = "github_light_default" }

---@type LazySpec
return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    set_dark_mode = function() vim.cmd.colorscheme(themes.dark) end,
    set_light_mode = function() vim.cmd.colorscheme(themes.light) end,
  },
  init = function()
    -- Anything that writes `background` without following up with `:colorscheme`
    -- leaves `g:colors_name` unset, i.e. on `default`: Neovim re-querying the
    -- terminal after a suspend/resume, or `<Leader>ub`. Put a theme back.
    vim.api.nvim_create_autocmd("OptionSet", {
      desc = "Restore a colorscheme when something changes 'background' on its own",
      pattern = "background",
      -- deferred so the check runs after any in-flight `:colorscheme` has finished
      callback = function()
        vim.schedule(function()
          if not vim.g.colors_name then vim.cmd.colorscheme(themes[vim.o.background]) end
        end)
      end,
    })
  end,
}
