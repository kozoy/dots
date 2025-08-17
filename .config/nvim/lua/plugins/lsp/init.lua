-- lua/plugins/lsp/init.lua
local enabled_servers = { "pyright", "ruff", "clangd", "harper_ls" }

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "gd", false }
      keys[#keys + 1] = { "gr", false }
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "<leader>cf", false } -- 禁用默认格式（用 conform 替代）
      keys[#keys + 1] = { "<leader>cc", false } -- 可选禁用代码镜头
      keys[#keys + 1] = { "D", vim.lsp.buf.hover, desc = "Hover" }
    end,
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.diagnostics = {
        update_in_insert = true,
        virtual_text = {
          severity = { vim.diagnostic.severity.INFO, vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
          prefix = "icons",
        },
        signs = {
          severity = { vim.diagnostic.severity.HINT },
          text = { [vim.diagnostic.severity.HINT] = "💡" },
        },
      }
      opts.inlay_hints = { enabled = false }

      for _, server in ipairs(enabled_servers) do
        opts.servers[server] = require("plugins.lsp.servers." .. server)
      end

      opts.format_notify = true
      return opts
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pyright", "ruff", "clangd", "harper-ls", "black", "isort" })
      return opts
    end,
  },

  {
    "stevearc/conform.nvim",
    keys = {
      { "<leader>cF", false },
      {
        "<leader>fm",
        "<cmd>LazyFormat<CR>",
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end
      -- 未来扩展：添加其他 ft 如 cpp = { "clang_format" }
      return opts
    end,
  },

  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.python = { "ruff" }
      -- 扩展示例：proto = { "buf_lint" }, markdown = { "harper_ls" } 但 harper_ls 是 LSP
      return opts
    end,
  },

  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    keys = {
      { "K", false },
      {
        "gd",
        "<cmd>Lspsaga peek_definition<cr>",
        desc = "Go to Definition",
      },
      {
        "gr",
        "<cmd>Lspsaga finder ++inexist<cr>",
        desc = "Go to References",
      },
      {
        "ga",
        "<cmd>Lspsaga code_action<cr>",
        mode = { "n", "v" },
        desc = "Code Action (preview)",
      },
      {
        "<leader>rn",
        "<cmd>Lspsaga rename ++project<cr>",
        mode = { "n", "v" },
        desc = "Rename in Project",
      },
    },
    opts = {
      request_timeout = 3000,
      symbol_in_winbar = {
        enable = not require("lazyvim.util").has("dropbar.nvim"),
      },
      code_action = {
        num_shortcut = true,
        show_server_name = true,
        extend_gitsigns = false,
        keys = { quit = "q", exec = "<CR>" },
      },
      definition = {
        width = 0.6,
        height = 0.5,
        keys = { edit = "<CR>", vsplit = "v", split = "s", tabe = "t" },
      },
      lightbulb = { enable = false },
      finder = {
        keys = { toggle_or_open = "<CR>", vsplit = "v", split = "s", tabe = "t" },
      },
      rename = {
        in_select = false,
        auto_save = false,
        project_max_width = 0.5,
        project_max_height = 0.5,
        keys = { quit = "<C-q>", exec = "<CR>", select = "x" },
      },
      scroll_preview = { scroll_down = "<C-d>", scroll_up = "<C-u>" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  },

  {
    "felpafel/inlay-hint.nvim",
    branch = "nightly",
    event = "LspAttach",
    opts = { virt_text_pos = "inline" },
    config = function()
      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          vim.lsp.inlay_hint.enable(false)
        end,
      })
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          vim.lsp.inlay_hint.enable(true)
        end,
      })
    end,
  },

  { "smjonas/inc-rename.nvim", opts = {} },
}
