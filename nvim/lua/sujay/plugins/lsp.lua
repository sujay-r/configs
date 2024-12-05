return {
    {
        "williamboman/mason.nvim",
        config = function()
            require('mason').setup({})
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            local mason_config = require('mason-lspconfig')

            mason_config.setup({
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end
                },
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.opt.signcolumn = "yes"

            local lspconfig_defaults = require('lspconfig').util.default_config
            lspconfig_defaults.capabilities = vim.tbl_deep_extend(
                'force',
                lspconfig_defaults.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            vim.g.python3_host_prog = "C:\\Users\\e27sa\\miniconda3\\envs\\neovim-env\\python.exe"
            local lspconfig = require("lspconfig")

            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP Actions',
                callback = function(event)
                    local opts = { buffer = event.buf }
                    
                    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                    -- vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                    vim.keymap.set('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                end,
            })
        end
    },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        run = "make install_jsregexp"
    },
    {"saadparwaiz1/cmp_luasnip"},
    {"hrsh7th/cmp-nvim-lsp"},
    {"hrsh7th/cmp-path"},
    {"hrsh7th/cmp-buffer"},
    {"onsails/lspkind.nvim"},
    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvimtools/none-ls-extras.nvim",
        },
        config = function()
            local null_ls = require('null-ls')
            local venv_path = vim.fn.getenv("VIRTUAL_ENV")

            null_ls.setup({
                sources = {
                    -- Python
                   require("none-ls.diagnostics.ruff"),
                    
                    -- Javascript
                    require("none-ls.diagnostics.eslint_d"),
                }
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "VenvActivated",
                callback = function()
                    require("null-ls").disable()
                    require("null-ls").enable()
                end
            })
        end,
    },
    {
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        keys = {
            {
                "<F3>",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },

        --@module "conform"
        --@type conform.setupOpts
        opts = {
            formatters_by_ft = {
                python = { 'isort', 'black' },
                javascript = { 'prettierd', 'prettier', stop_after_first = true },
            },
            default_format_opts = {
                lsp_format = 'fallback',
            },
            format_on_save = { timeout_ms = 1000 },
            formatters = {
                shfmt = {
                    prepend_args = { '-i', '2' },
                },
                isort = {
                    include_trailing_comma = true,
                    command = "isort",
                    args = {
                        "--line-length",
                        "79",
                        "--lines-after-import",
                        "2",
                        "--quiet",
                        "-",
                    },
                },
                black = {
                    command = "black",
                    args = {
                        "--line-length",
                        "79",
                        "--quiet",
                        "-",
                    },
                },
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require('cmp')
            local lspkind = require('lspkind')
            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup({
                sources = {
                    {name = 'nvim_lsp'},
                    {name = 'luasnip'},
                    {name = 'buffer'},
                    {name = 'path'},
                },
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                preselect = 'item',
                completion = {
                    completeopt = 'menu,menuone,noinsert'
                },
                formatting = {
                    format = lspkind.cmp_format({
                        mode = 'symbol',
                        maxwidth = {
                            menu = 50,
                            abbr = 50,
                        },
                        ellipsis_char = '...',
                        show_labelDetails = true,
                    })
                },
                mapping = cmp.mapping.preset.insert({
                    -- Jump to next snippet placeholder
                    ['<C-f>'] = cmp.mapping(function(fallback)
                        local luasnip = require('luasnip')
                        if luasnip.locally_jumpable(1) then
                            luasnip.jump(1)
                        else
                            fallback()
                        end
                    end, {'i', 's'}),

                    -- Jump to previous snippet placeholder
                    ['<C-b>'] = cmp.mapping(function(fallback)
                        local luasnip = require('luasnip')
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {'i', 's'}),
                }),
            })
        end
    },
}
