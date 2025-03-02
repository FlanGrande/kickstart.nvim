--[[

=====================================================================
==================== read this before continuing ====================
=====================================================================

kickstart.nvim is *not* a distribution.

kickstart.nvim is a template for your own configuration.
  the goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  once you've done that, you should start exploring, configuring and tinkering to
  explore neovim!

  if you don't know anything about lua, i recommend taking some time to read through
  a guide. one possible example:
  - https://learnxinyminutes.com/docs/lua/

  and then you can explore or search through `:help lua-guide`


kickstart guide:

i have left several `:help x` comments throughout the init.lua
you should run that command and read that help section for more information.

in addition, i have some `note:` items throughout the file.
these are for you, the reader to help understand what is happening. feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

i hope you enjoy your neovim journey,
- tj

p.s. you can delete this when you're done too. it's your config now :)
--]]
-- set <space> as the leader key
-- see `:help mapleader`
--  note: must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.o.pumheight = 20

-- set to true if you have a nerd font installed and selected in the terminal
vim.g.have_nerd_font = true

-- enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- highlights line where cursor is
vim.opt.cursorline = true
-- vim.api.nvim_set_hl(0, "CustomCursorLine", { bg = "#ff0000", bold = false, ctermbg = 88, link = "CursorLine" })
-- vim.opt.winhighlight = "CursorLine:Visual"

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-cmdline',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          -- local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          --   local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          --   vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          --     buffer = event.buf,
          --     group = highlight_augroup,
          --     callback = vim.lsp.buf.document_highlight,
          --   })
          --
          --   vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          --     buffer = event.buf,
          --     group = highlight_augroup,
          --     callback = vim.lsp.buf.clear_references,
          --   })
          --
          --   vim.api.nvim_create_autocmd('LspDetach', {
          --     group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          --     callback = function(event2)
          --       vim.lsp.buf.clear_references()
          --       vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          --     end,
          --   })
          -- end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          settings = {
            Lua = {
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      -- 'hrsh7th/cmp-cmdline',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'

      cmp.setup {
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        -- mapping = cmp.mapping.preset.insert {
        --   -- Select the [n]ext item
        --   ['<C-j>'] = cmp.mapping.select_next_item(),
        --   -- Select the [p]revious item
        --   ['<C-k>'] = cmp.mapping.select_prev_item(),
        --
        --   -- Scroll the documentation window [b]ack / [f]orward
        --   ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        --   ['<C-f>'] = cmp.mapping.scroll_docs(4),
        --
        --   -- Accept ([y]es) the completion.
        --   --  This will auto-import if your LSP supports it.
        --   --  This will expand snippets if the LSP sent a snippet.
        --   ['<C-y>'] = cmp.mapping.confirm { select = true },
        --
        --   -- Manually trigger a completion from nvim-cmp.
        --   --  Generally you don't need this, because nvim-cmp will display
        --   --  completions whenever it has completion options available.
        --   ['<C-Space>'] = cmp.mapping.complete {},
        --
        --   ['<Up>'] = cmp.mapping.abort(),
        --   ['<Down>'] = cmp.mapping.abort(),
        --   ['<Tab>'] = cmp.mapping.abort(),
        --   ['<S-Tab>'] = cmp.mapping.abort(),
        --   ['<C-p>'] = cmp.mapping.abort(),
        --   ['<C-n>'] = cmp.mapping.abort(),
        -- },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim', opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = {}
      },
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },

  {
    'fcpg/vim-fahrenheit',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'fahrenheit'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {
      indent = {
        char = '┊',
      },
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },




  -- Mine

  {
    'ThePrimeagen/vim-be-good'
  },

  {
    'ThePrimeagen/harpoon'
  },

  {
    'mbbill/undotree'
  },

  {
    'BurntSushi/ripgrep'
  },

  {
    'stevearc/dressing.nvim'
  },

  {
    'MunifTanjim/nui.nvim'
  },

  {
    'sphamba/smear-cursor.nvim',
    opts = {
      stiffness = 0.7,
      trailing_stiffness = 0.4,
      distance_stop_animating = 0.3
    },
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      -- add any opts here
      -- for example
      provider = "openai",
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- timeout in milliseconds
        temperature = 0, -- adjust if needed
        max_tokens = 4096,
        -- reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
      },
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 8000,
      },
      file_selector = {
        provider = "telescope",
        -- Options override for custom providers
        provider_opts = {},
      }
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }




  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- This one is recommended for avante.nvim
-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
-- vim.wo.number = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Unmap <C-k> and <C-j> in insert mode to avoid conflicts with cmp
-- vim.keymap.del('i', '<C-k>')
-- vim.keymap.del('i', '<C-j>')

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-q>', '', { noremap = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    winblend = 0,
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
      n = {
        ['<C-q>'] = actions.smart_add_to_qflist,
      },
    },
    file_ignore_patterns = {
      "node_modules",
      "@sveltekit/kit",
      ".svelte%-kit",
      ".git"
    }
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' }) vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 0,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [Resume]' })
vim.keymap.set('n', '<leader>s.', require('telescope.builtin').oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sq', require('telescope.builtin').quickfix, { desc = '[S]earch [Q]uickfix List' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'html', 'javascript', 'lua', 'python', 'scss', 'vimdoc', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  indent = { enable = true },
  -- incremental_selection = {
  --   enable = true,
  --   keymaps = {
  --     init_selection = '<C-Space>',
  --     node_incremental = '<C-Space>',
  --     scope_incremental = '<C-S>',
  --     node_decremental = '<M-Space>',
  --   },
  -- },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- local lsp = require('lsp-zero').preset({
--   name = 'minimal',
--   set_lsp_keymaps = false,
-- })
--

-- lsp.on_attach(function(client, bufnr)
--   -- see :help lsp-zero-keybindings
--   -- to learn the available actions
--   -- lsp.default_keymaps({buffer = bufnr})
-- end)

-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
--
-- lsp.setup()
--
-- Setup neovim lua configuration
-- require('neodev').setup()




-- Mine


require('harpoon').setup()
local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.o.wrap = false;

-- Harpoon keymaps
vim.keymap.set('n', '<leader>ha', mark.add_file, { desc = '[A]dd to Harpoon' })
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)

vim.keymap.set('n', '<F1>', function() ui.nav_file(1) end)
vim.keymap.set('n', '<F2>', function() ui.nav_file(2) end)
vim.keymap.set('n', '<F3>', function() ui.nav_file(3) end)
vim.keymap.set('n', '<F4>', function() ui.nav_file(4) end)
vim.keymap.set('n', '<F5>', function() ui.nav_file(5) end)
vim.keymap.set('n', '<F6>', function() ui.nav_file(6) end)
vim.keymap.set('n', '<F7>', function() ui.nav_file(7) end)
vim.keymap.set('n', '<F8>', function() ui.nav_file(8) end)

-- Undotree keymap
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndo Tree' })

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath('config') .. '/undodir'
vim.opt.undofile = true

-- Set numbers on the left side
vim.opt.nu = true

-- Set relative number
vim.o.relativenumber = true

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

-- Copied from ThePrimeagen
-- Move content of line up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Keep cursor centered
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Paste without copying to clipboard
-- vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste without copying to clipboard' })

-- Replace current word
vim.keymap.set('n', '<leader>r', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>', { desc = 'Replace current word' })


-- Undotree options
vim.g.undotree_WindowLayout = 4
vim.g.undotree_SetFocusWhenToggle = 1

-- Change blankline color
vim.cmd('hi IndentBlankLineChar guifg=#442211 gui=nocombine')

-- Help on hovered word
vim.keymap.set('n', 'K', ':help <C-r><C-w><CR>', { noremap = true, silent = true })


local cmp = require('cmp')

-- Setup for insert mode
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-y>'] = cmp.mapping.confirm { select = true },
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<Up>'] = cmp.mapping.abort(),
    ['<Down>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.abort(),
    ['<S-Tab>'] = cmp.mapping.abort(),
    ['<C-p>'] = cmp.mapping.abort(),
    ['<C-n>'] = cmp.mapping.abort(),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
  },
})

-- Setup for command-line mode
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline({
    ['<C-j>'] = cmp.mapping({
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    }),
    ['<C-k>'] = cmp.mapping({
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    }),
    ['<C-e>'] = cmp.mapping({
      c = cmp.mapping.abort(),
    }),
    ['<Up>'] = cmp.mapping({
      c = cmp.mapping.abort(),
    }),
    ['<Down>'] = cmp.mapping({
      c = cmp.mapping.abort(),
    }),
    ['<C-y>'] = cmp.mapping({
      c = cmp.mapping.confirm({ select = false }),
    }),
  }),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})

-- reset Tab and S-Tab behaviour
vim.keymap.set('i', '<Tab>', '<Tab>', { noremap = true, silent = true })
vim.keymap.set('i', '<S-Tab>', '<C-d>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-j>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<C-k>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<C-l>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<C-p>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<C-n>', '', { noremap = true, silent = true })


vim.keymap.set('c', '<C-j>', '', { noremap = true, silent = true })
vim.keymap.set('c', '<C-k>', '', { noremap = true, silent = true })
vim.keymap.set('c', '<C-p>', '', { noremap = true, silent = true })
vim.keymap.set('c', '<C-n>', '', { noremap = true, silent = true })


vim.keymap.set('i', '<F1>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F2>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F3>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F4>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F5>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F6>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F7>', '', { noremap = true, silent = true })
vim.keymap.set('i', '<F8>', '', { noremap = true, silent = true })


-- End Mine




-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
