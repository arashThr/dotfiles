local use = require('packer').use
require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'neovim/nvim-lspconfig'

	use 'nvim-telescope/telescope.nvim'
	use 'nvim-lua/plenary.nvim'

	use 'nvim-treesitter/nvim-treesitter'

	-- use 'tpope/vim-fugitive'
	-- use 'airblade/vim-gitgutter'

	use 'preservim/nerdtree'

	use {
		"kdheepak/lazygit.nvim",
		requires = { "nvim-lua/plenary.nvim" }
	}

	use 'github/copilot.vim'

	use 'hrsh7th/nvim-cmp'           -- Restore completion
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'    -- Words from current buffer
	use 'hrsh7th/cmp-path'      -- File paths
	use 'hrsh7th/cmp-cmdline'   -- Command line completion

	use 'vimwiki/vimwiki'
	use 'ggandor/leap.nvim'          -- Fast jumping
	use 'mbbill/undotree'             -- Undo tree
	use 'folke/which-key.nvim'       -- Key hints
	use 'nvim-lualine/lualine.nvim'  -- Status line
	use 'tpope/vim-surround'            -- Change surrounding quotes/brackets
	use 'windwp/nvim-autopairs'         -- Auto-close brackets
	use 'lewis6991/gitsigns.nvim'       -- Better git signs
end)

-- Setup gopls
local lspconfig = require('lspconfig')
lspconfig.gopls.setup {
	settings = {
		gopls = {
			buildFlags = { "-tags=integration_test" }
		}
	}
}

-- LSP keymaps
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})

-- Telescope
require('telescope').setup {
	defaults = {
		file_ignore_patterns = { "node_modules" },
		-- Add these fuzzy matching options
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
		},
		-- Better file sorting
		file_sorter = require("telescope.sorters").get_fzy_sorter,
		generic_sorter = require("telescope.sorters").get_fzy_sorter,
	},
	pickers = {
		buffers = {
			sort_mru = true,
			ignore_current_buffer = true
		},
		-- Add fuzzy finding to file pickers
		find_files = {
			find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
		},
	}
}

vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
vim.keymap.set('n', '<F6>', vim.cmd.UndotreeToggle)

require('lualine').setup {
	options = {
		theme = 'auto',
		icons_enabled = true,
		component_separators = { left = '|', right = '|'},
		section_separators = { left = '', right = ''},
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	},
}
