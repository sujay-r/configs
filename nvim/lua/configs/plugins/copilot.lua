local fmt = string.format

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
	},
	{
		"github/copilot.vim",
		event = { "BufWinEnter" },
		init = function()
			vim.g.copilot_no_maps = true
		end,
		config = function()
			-- Block the normal copilot suggestions
			vim.api.nvim_create_augroup("github_copilot", { clear = true })
			vim.api.nvim_create_autocmd({ "FileType", "BufUnload" }, {
				group = "github_copilot",
				callback = function(args)
					vim.fn["copilot#On" .. args.event]()
				end,
			})
			vim.fn["copilot#OnFileType"]()
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"j-hui/fidget.nvim",
		},
		opts = {
			send_code = true,
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
					opts = {
						-- MCP Tools
						make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
						show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
						add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
						show_result_in_chat = true, -- Show tool results directly in chat buffer
						format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
						-- MCP Resources
						make_vars = true, -- Convert MCP resources to #variables for prompts
						-- MCP Prompts
						make_slash_commands = true, -- Add MCP prompts as /slash commands
					},
				},
			},
			adapters = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "gpt-4.1",
							},
						},
					})
				end,
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						schema = {
							model = {
								default = function()
									return "gpt-4o"
								end,
							},
						},
					})
				end,
				ollama = function()
					return require("codecompanion.adapters").extend("ollama", {
						schema = {
							num_ctx = {
								default = 20000,
							},
						},
					})
				end,
				llamacpp = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						env = {
							url = "",
							chat_url = "/v1/chat/completions",
							models_endpoint = "/v1/models",
						},
						schema = {
							model = {
								default = "llama",
							},
						},
					})
				end,
			},
			prompt_library = {
				["Generate Unit Tests"] = {
					strategy = "workflow",
					description = "Generate unit tests for the current directory of code",
					opts = {
						auto_submit = true,
						stop_context_insertion = true,
						user_prompt = true,
					},
					prompts = {
						{
							{
								role = "user",
								content = function()
									vim.g.codecompanion_auto_tool_mode = true

									return [[### INSTRUCTIONS

Your current task is to discover all the python modules in the specified directory so that you can generate unit tests for them.

#### Steps to follow:
1. Get the directory structure of the current module using the @{neovim__list_directory} tool.
2. Once you understand the directory, read through all the files using @{neovim__read_multiple_files} tool.
3. Generate an appropriate directory for the tests using the @{files} tool (if not already present, if present skip this step).
4. Generate unit test cases for all the code files and add them into the appropriate test file using the @{insert_edit_into_file} tool. Make sure to cover edge cases well.
5. Then use the @{cmd_runner} tool to run the test suite with `<test_cmd>`. (do this after you are done updating the code)

We will do this in multiple iterations until the unit test case creation is finished.

If no directory is specified, do it for the current directory.
]]
								end,
							},
							{
								role = "user",
								opts = { auto_submit = false },
								content = "Generate unit tests for the directory: ",
							},
						},
						{
							{
								name = "Repeat until finished",
								role = "user",
								content = "Are you finished with the unit test case creation? If not, please continue. If yes, reply '[DONE]'",
								opts = { auto_submit = true },
								repeat_until = function(chat)
									local config = require("codecompanion.config")
									local index = #chat.messages
									local llm_content
									while index > 0 do
										local message = chat.messages[index]
										if message.role == config.constants.LLM_ROLE then
											llm_content = message.content
											break
										end
										index = index - 1
									end

									return string.find(llm_content, "[DONE]") ~= nil
								end,
							},
						},
					},
				},
				["Activate serena project"] = {
					strategy = "workflow",
					description = "Activates the current project with serena",
					opts = {
						auto_submit = true,
						stop_context_insertion = true,
					},
					prompts = {
						{
							{
								role = "user",
								opts = { auto_submit = false },
								content = "Use @{serena} to activate the project `/path/to/project/here`. Keep the explanations to a minimum and just call tools.",
							},
						},
						{
							{
								name = "Prompt again on failure/premature stoppage",
								role = "user",
								content = "Are you finished with the onboarding? If not, please continue again. If yes, reply '[DONE]'.",
								opts = { auto_submit = true },
								repeat_until = function(chat)
									local config = require("codecompanion.config")
									local index = #chat.messages
									local llm_content
									while index > 0 do
										local message = chat.messages[index]
										if message.role == config.constants.LLM_ROLE then
											llm_content = message.content
											break
										end
										index = index - 1
									end

									return string.find(llm_content, "[DONE]") ~= nil
								end,
							},
						},
					},
				},
				["Explain code"] = {
					strategy = "workflow",
					description = "Explains the codebase using serena",
					opts = {
						auto_submit = true,
						stop_context_insertion = true,
					},
					prompts = {
						{
							{
								role = "user",
								content = "Use @{serena}, and explain to me ...",
								opts = { auto_submit = false },
							},
						},
						{
							{
								name = "Prompt again on failure/premature stoppage",
								role = "user",
								content = "Are you finished with the explanation? If not, please continue again. If yes, reply '[DONE]'.",
								opts = { auto_submit = true },
								repeat_until = function(chat)
									local config = require("codecompanion.config")
									local index = #chat.messages
									local llm_content
									while index > 0 do
										local message = chat.messages[index]
										if message.role == config.constants.LLM_ROLE then
											llm_content = message.content
											break
										end
										index = index - 1
									end

									return string.find(llm_content, "[DONE]") ~= nil
								end,
							},
						},
					},
				},
			},
			strategies = {
				chat = {
					adapter = "llamacpp",
				},
				inline = {
					adapter = "llamacpp",
				},
				cmd = {
					adapter = "llamacpp",
				},
			},
		},
		init = function()
			require("configs.extra_setup.fidget-spinner"):init()

			vim.keymap.set(
				{ "n", "v" },
				"<leader>ca",
				"<cmd>CodeCompanionActions<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set({ "n", "v" }, "<leader>cp", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })
			vim.keymap.set(
				{ "n", "v" },
				"<leader>cc",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<leader>ga",
				"<cmd>CodeCompanionChat Add<cr>",
				{ noremap = true, silent = true }
			)
		end,
	},
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = "npm install -g mcp-hub@latest",
		config = function()
			require("mcphub").setup()
		end,
	},
}
