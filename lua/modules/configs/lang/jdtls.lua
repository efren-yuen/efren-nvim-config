local ok, jdtls = pcall(require, "jdtls")
if not ok then
	vim.notify("Could not load jdtls")
	return
end

local ok, mason = pcall(require, "mason-registry")
if not ok then
	vim.notify("Could not load mason-registry")
	return
end

local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not ok then
	vim.notify("Could not load nvim-cmp")
	return
end
-- local default = require("language.default")

-- local HOME = os.getenv "HOME"
-- local WORKSPACE_PATH = HOME .. "/workspace/java/"
-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
-- local workspace_dir = WORKSPACE_PATH .. project_name

local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	-- Disable semantic tokens
	client.server_capabilities.semanticTokensProvider = nil
end
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {
		mason.get_package("jdtls"):get_install_path() .. "/bin/jdtls",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms8g",
		"-Xmx8g",
		"-XX:ReservedCodeCacheSize=1024m",
		"-XX:+UseCompressedOops",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"--jvm-arg=-javaagent:/home/efren/Documents/lombok.jar",

		-- "java", -- or '/path/to/java11_or_newer/bin/java'
		-- -- depends on if `java` is in your $PATH env variable and if it points to the right version.
		-- "-Declipse.application=org.eclipse.jdt.ls.core.id1",
		-- "-Dosgi.bundles.defaultStartLevel=4",
		-- "-Declipse.product=org.eclipse.jdt.ls.core.product",
		-- "-Dlog.protocol=true",
		-- "-Dlog.level=ALL",
		-- -- "-javaagent:" .. home .. "/.local/share/nvim/lsp_servers/jdtls/lombok.jar",
		-- -- "-javaagent:" .. "/home/efren/.local/share/nvim/mason/packages/jdtls/lombok.jar",
		-- "-Xms1g",
		-- "--add-modules=ALL-SYSTEM",

		-- "--add-opens",
		-- "java.base/java.util=ALL-UNNAMED",
		-- "--add-opens",
		-- "java.base/java.lang=ALL-UNNAMED",

		-- -- 💀
		-- "-jar",
		-- vim.fn.glob("/home/efren/.local/share/nvim/mason/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
		-- -- vim.fn.glob(home .. "/Downloads/jdt-language-server-1.9.0-202203031534/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"),
		-- -- "/home/efren/Downloads/jdt-language-server-1.9.0-202203031534/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
		-- -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
		-- -- Must point to the                                                     Change this to
		-- -- eclipse.jdt.ls installation                                           the actual version

		-- -- 💀
		-- "-configuration",
		-- -- home .. "/.local/share/nvim/lsp_servers/jdtls/config_" .. CONFIG,
		-- "/home/efren/.local/share/nvim/mason/jdtls/config_linux",
		-- -- "/home/efren/Downloads/jdt-language-server-1.9.0-202203031534/config_linux",
		-- -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
		-- -- Must point to the                      Change to one of `linux`, `win` or `mac`
		-- -- eclipse.jdt.ls installation            Depending on your system.

		-- -- 💀
		-- -- See `data directory configuration` section in the README
		-- "-data",
		-- workspace_dir,
	},

	-- 💀
	-- This is the default if not provided, you can remove it. Or adjust as needed.
	-- One dedicated LSP server & client will be started per unique root_dir
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-1.8",
						path = "/usr/lib/jvm/java-8-openjdk/",
						default = true,
					},
					{
						name = "JavaSE-17",
						path = "/usr/lib/jvm/java-17-openjdk/",
					},
					{
						name = "JavaSE-19",
						path = "/usr/lib/jvm/java-19-jdk/",
					},
				},
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
			},
		},
	},

	capabilities = cmp_nvim_lsp.default_capabilities(),

	on_attach = function(client, bufnr)
		-- vim.notify("client:" .. bufnr)
		-- on_attach(client, bufnr)

		-- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
		-- you make during a debug session immediately.
		-- Remove the option if you do not want that.
		-- You can use the `JdtHotcodeReplace` command to trigger it manually
		jdtls.setup_dap({ hotcodereplace = "auto" })
		-- require("jdtls.dap").setup_dap_main_class_configs()
		require("jdtls.setup").add_commands()
	end,

	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = {
			vim.fn.glob(
				mason.get_package("java-debug-adapter"):get_install_path()
					.. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
				1
			),
		},
	},
}

vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = "java",
	callback = function()
		-- This starts a new client & server,
		-- or attaches to an existing client & server depending on the `root_dir`.
		jdtls.start_or_attach(config)
		vim.bo.tabstop = 4
	end,
})
