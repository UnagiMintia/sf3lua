print("unagi lua script")

--[[
	ファイル名:000_unagi.lua
	説明:メイン的なやつ。

	コーディングにあたって覚えておくこと
		luaでは先に定義しておかないとファンクション呼べないのとかを気を付ける。
		常に画面は描画され直しているので、gui.textとかは一度出しただけでは一瞬で消える。
		画面に表示し続ける必要があるならgui.registerの中で描画し続けるようにする。
		困ったら http://gocha.is.land.to/down/public/gens-lua-ja.html とかを頑張って読む。
]]

--別ファイル読み込み
require("010_PrmSet")

--パブリック変数
local pNowFrm = 0
local pRegCnt = 0
local ptest = 0

--[[
	自作関数
	変数の初期化
]]
function fIni()
end

--[[
	自作関数
	1フレーム毎に呼ばれる処理
]]
function fFrm()

	--毎フレーム効かせるチート

	--毎フレーム書きだすプリント
	
end


--[[
	自作関数
	調査をする上で、複数の値を常に表示しておきたい場合に使う
	例えば、メモリサーチをうんたん
]]
function fTxt()

end


--[[
	用意されてるやつ。
	描画のタイミングで常に実行され続ける。実際に何フレーム分に相当するかかはちょっとよく分からない。今度数えてみよう。
  
]]
gui.register(function()
	pRegCnt = pRegCnt + 1
	if pNowFrm == 0 then
		pNowFrm = emu.framecount()
	elseif pNowFrm < emu.framecount() then
		pNowFrm = emu.framecount()
		--1フレーム毎の処理をコール
		fFrm()
	end


	gui.text(30,20,"pRegCnt        : " .. pRegCnt)
	gui.text(30,30,"emu.framecount : " .. emu.framecount())
end)

--[[
	用意されてるやつ。
	ホットキー1を押される度に動作するファンクション
]]
input.registerhotkey(1, function()
end)

--[[
	用意されてるやつ。
	ホットキー2を押される度に動作するファンクション
]]
input.registerhotkey(2, function()
end)

--[[
	用意されてるやつ。
	ホットキー3を押される度に動作するファンクション
]]
input.registerhotkey(3, function()
end)

--[[
	用意されてるやつ。
	ホットキー4を押される度に動作するファンクション
]]
input.registerhotkey(4, function()
end)

--[[
	用意されてるやつ。
	ホットキー5を押される度に動作するファンクション
]]
input.registerhotkey(5, function()
end)

--[[
	用意されてるやつ。
	ロードされたタイミングで呼ばれるファンクション
]]
savestate.registerload(function()
end)

--[[
	用意されてるやつ。
	エミュレータ起動時に呼ばれるファンクション
]]
emu.registerstart(function()
end)

--[[
	用意されてるやつ。
ロードが完了する前/セーブされたタイミングで呼ばれるファンクション
]]
savestate.registersave(function()
end)

