return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use the latest release instead of the latest commit
  -- Load eagerly when nvim is started *inside* the vault (e.g. `cd ~/notodes && nvim`),
  -- otherwise stay lazy and load on note-open. getcwd() is evaluated when lazy.nvim
  -- reads this spec at startup, which is the directory nvim was launched in.
  lazy = not vim.startswith(vim.fn.getcwd(), vim.env.HOME .. "/notodes"),
  -- Fallback lazy-load on any markdown file inside the vault (the `**` covers
  -- subdirs like Diarya/ and templates/) for when you open notes from elsewhere.
  event = { "BufReadPre */notodes/**/*.md" },

  dependencies = {
    "nvim-lua/plenary.nvim",
    { "hrsh7th/nvim-cmp", optional = true },
    "AstroNvim/astrocore",
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = function(_, opts)
    local astrocore = require "astrocore"
    return astrocore.extend_tbl(opts, {
      legacy_commands = false, -- opt into the `:Obsidian <subcommand>` syntax

      workspaces = {
        {
          name = "notodes",
          path = vim.env.HOME .. "/notodes", -- no need to call 'vim.fn.expand' here
        },
      },

      open = {
        use_advanced_uri = true,
        -- `func` defaults to vim.ui.open, so the old `follow_url_func` line is no longer needed.
      },

      -- `finder` is now `picker = { name = ... }`.
      picker = {
        name = (astrocore.is_available "snacks.pick" and "snacks.pick")
          or (astrocore.is_available "telescope.nvim" and "telescope.nvim")
          or (astrocore.is_available "fzf-lua" and "fzf-lua")
          or (astrocore.is_available "mini.pick" and "mini.pick"),
      },

      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },

      daily_notes = {
        folder = "Diarya",
      },

      -- Engine (nvim-cmp / blink) is auto-detected now; the old
      -- `completion.nvim_cmp` / `completion.blink` flags are gone.
      completion = {
        min_chars = 2,
      },

      -- Checkbox state cycle for `:Obsidian toggle_checkbox` / smart_action.
      -- Ordering lives here now, NOT in `ui.checkboxes` (see obsidian.nvim#262).
      -- Empty -> Done first so a single toggle marks a task complete, then a
      -- pending "." in-progress state, then the remaining marks.
      checkbox = {
        order = { " ", "x", ".", "~", "!", ">" },
      },

      -- Rendered glyphs per mark. Deep-merges with the plugin defaults, so we only
      -- add the new pending "." here. Requires conceallevel >= 1 (set per-note in
      -- enter_note below) for the raw `[ ]` text to be concealed behind the icon.
      ui = {
        checkboxes = {
          ["."] = { char = "󰔟", hl_group = "ObsidianPending" },
        },
        hl_groups = {
          ObsidianPending = { bold = true, fg = "#ffcb6b" },
        },
      },

      -- You previously returned an empty table from note_frontmatter_func,
      -- i.e. "don't manage frontmatter" — the modern way is:
      frontmatter = {
        enabled = false,
      },

      -- Clean, title-based filenames instead of the default Zettelkasten
      -- "<timestamp>-<random>" IDs. Falls back to a timestamp for untitled notes.
      note_id_func = function(title)
        if title ~= nil then
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        end
        return tostring(os.time())
      end,

      -- Note-local keymaps live here now (only active inside vault notes).
      callbacks = {
        enter_note = function(note)
          -- Conceal the raw `[ ]`/`[x]` markup so the ui.checkboxes glyphs show.
          vim.opt_local.conceallevel = 2

          vim.keymap.set("n", "gf", function()
            if require("obsidian.api").cursor_link() then
              return "<Cmd>Obsidian follow_link<CR>"
            else
              return "gf"
            end
          end, { buffer = note.bufnr, expr = true, desc = "Obsidian Follow Link" })
        end,
      },
    })
  end,
}
