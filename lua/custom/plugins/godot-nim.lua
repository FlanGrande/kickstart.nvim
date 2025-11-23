-- Godot specific
local GodotNimTerminal  = require('toggleterm.terminal').Terminal
local root = vim.fs.root(0, '.git')
local godotbuildgame = GodotNimTerminal:new({ cmd = "gdextwiz build", dir = root, hidden = true, close_on_exit = false })
local godotrungame = GodotNimTerminal:new({ cmd = "godot godot/main.tscn", dir = root, hidden = true, close_on_exit = false })
local godotrungamecolliders = GodotNimTerminal:new({ cmd = "godot godot/main.tscn --debug-collisions" , dir = root, hidden = true, close_on_exit = false })
  
function _build_godot_game() godotbuildgame:toggle() end
function _run_godot_game() godotrungame:toggle() end
function _run_godot_game_with_colliders() godotrungamecolliders:toggle() end

vim.keymap.set('n', '<leader>nb', '<cmd>lua _build_godot_game()<CR>', { noremap = true, silent = true, desc = "Godot-[N]im [B]uild game" })
vim.keymap.set('n', '<leader>ng', '<cmd>lua _run_godot_game()<CR>', { noremap = true, silent = true, desc = "Godot-[N]im run [G]ame" })
vim.keymap.set('n', '<leader>nc', '<cmd>lua _run_godot_game_with_colliders()<CR>', { noremap = true, silent = true, desc = "Godot-[N]im run game with [C]olliders" })


-- Snippets
local ls = require('luasnip')

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local rep = require("luasnip.extras").rep


ls.add_snippets("nim", {
	s("gdimport", {
		t("import gdext/classes/gd"),
		i(1, "Godot built-in class")
	}),
	s("gdvar", {
		i(1, "Variable"),
		t("* {.gdexport.}: "),
		i(2, "Type"),
	}),
	s("proc", {
		t("proc "),
		i(1, "procName"),
		t("(self: "),
		i(2, "SelfType"),
		t("): "),
		i(3, "ReturnType"),
	}),
	s("gdsignal", {
		t("proc "),
		i(1, "signal_name"),
		t("(self: "),
		i(2, "SelfType"),
		t("): Error {.gdsync, signal.}"),
	}),
	s("gdconnect_signal", {
		t("discard "),
		i(1, "signal_emitter_node"),
		t('.connect("'),
		i(2, "signal_name"),
		t('", self.callable("_on_'),
		rep(2),
		t('"))')
	}),
	s("gd_on_body_entered", {
		t('proc on_body_entered(self: '),
		i(1, "SelfType"),
		t(', body: Node2D) {.gdsync, name: "_on_body_entered".} ='),
	}),
	s("gd_on_body_exited", {
		t('proc on_body_exited(self: '),
		i(1, "SelfType"),
		t(', body: Node2D) {.gdsync, name: "_on_body_exited".} ='),
	}),
	s("gdnewscript", {
		t({
			"#nim/nimmain/src/classes/"
		}),
		i(1, "nodename"),
		t({
			".nim",
			"",
		}),
		t({
			"import gdext",
			"import gdext/classes/gd",
		}),
		i(2, "NodeType"),
		t({
			"",
			"",
			"type ",
		}),
		i(3, "NodeName"),
		t({"* {.gdsync.} = ptr object of "}),
		rep(2),
		t({
			"",
			"",
			"",
			"method ready(self: ",
		}),
		rep(3),
		t({
			") {.gdsync.} =",
			"\tdiscard",
			"",
			"method process(self: "}),
		rep(3),
		t({
			", delta: float64) {.gdsync.} =",
			"\tdiscard",
		})
	})
})
