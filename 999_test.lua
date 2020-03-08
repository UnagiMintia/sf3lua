print("test lua script")

--[[
	ファイル名:000_unagi.lua
	説明:メイン的なやつ。

	コーディングにあたって覚えておくこと
		luaでは先に定義しておかないとファンクション呼べないのとかを気を付ける。
		常に画面は描画され直しているので、gui.textとかは一度出しただけでは一瞬で消える。
		画面に表示し続ける必要があるならgui.registerの中で描画し続けるようにする。
		困ったら http://gocha.is.land.to/down/public/gens-lua-ja.html とかを頑張って読む。
    
  文字コードについて何で書くのがいいか思案中
    ソースはUTF-8で書いているが、FBA-rrでの挙動はこんな感じ
    gui.text・・・文字化けはしないが、全角文字はすべて表示されず文字が詰められる　例： 文字化けテストabc ⇒ abc
    print・・・Shift-JISに変換されて表示される。ソースをShift-JISで書いておけばちゃんと出る。 
    
    なので、Shift-JISで書けばprintは出るものの、gui.textには表示する方法が無いかも。
 これはgdライブラリのstringFTを使うことで解消できた。
 pImgMen:stringFT(white, "msgothic.ttc", 20, 0, 10, 60, "あいうえお")
 
  gui.うんたんは最後に実行されたものが残る。そのため、常に描画し続けるか、一度で全部描ききるか。
  
  fba-rrのconfigure hotkeysは、単体起動後に設定して抜けると保存される模様。ロムを読み込んでから変えると反映されない？
]]

--別ファイル読み込み
require("010_PrmSet")
require("011_ComFnc")
require("gd")

--カウント用、フレーム用
local pNowFrm = 0

--定数系テーブルオブジェクト
local pMem
local pCon

--変数系テーブルオブジェクト
local pNowMemSts = {}

local pInpJoyPad = {}         --キー入力の受け皿
local pInpJoyCst = {}         --入力されたキー情報の追加情報入力用
local pBefJoyPad = {}         --1フレーム前のキー入力保存用
local pBefJoyCst = {}         --1フレーム前の入力されたキー情報の追加情報入力用
local pSetPad = {}        --キー設定用

--[[
	自作関数
	毎フレーム効かせるチート
]]
function fCht()
  
  memory.writebyte(pMem.RndTim,0x64)  --時間MAX
--  memory.writebyte(pMem.SelCha1Pl,0x0F)  --
--  memory.writebyte(pMem.SelCha2Pl,0x00)  --
--  memory.writebyte(pMem.SelSar1Pl,0x02)  --
--  memory.writebyte(pMem.SelSar2Pl,0x01)  --
--  memory.writebyte(pMem.SelCol1Pl,0x03)  --
--  memory.writebyte(pMem.SelCol2Pl,0x04)  --
--  memory.writebyte(pMem.SelStg,0x10)  --
--  memory.writebyte(pMem.Vit1Pl,0x00)

    memory.writebyte(pMem.Vit1Pl,0xA0)
    memory.writebyte(pMem.Vit2Pl,0xA0)
end

--[[
	自作関数
	ステートロード時の変数の初期化
]]
function fLodIni()
  pNowFrm = emu.framecount()
  
  --メモリ情報取得
  local key, val
  for key, val in pairs(pMem) do
    pNowMemSts[key] = memory.readbyte(val)
  end
end

--[[
	自作関数
	lua有効時の変数の初期化
]]
function fIni()
  
  --定数
  pMem = fMemAdrSet_010()
  pCon = fConValSet_010()

  --ロード時用の初期化ファンクション
  fLodIni()
  
end

--[[
	自作関数
	常に実行され続ける。
]]
function fManReg()
  if pNowFrm == 0 then
		pNowFrm = emu.framecount()
	elseif pNowFrm < emu.framecount() then
		pNowFrm = emu.framecount()
		--1フレーム毎の処理をコール
		fFrm()
  end 
  
end
--[[
	自作関数
	1フレーム毎に呼ばれる処理
]]
function fFrm()
	
  --メニューで指示されたチートを実行
	fCht()
  
  --メモリ情報取得
  local key, val
  for key, val in pairs(pMem) do
    pNowMemSts[key] = memory.readbyte(val)
  end

--[[
  gui.text(30,30,f2Str_011(joypad.get()["P1 Up"]))
  gui.text(30,40,f2Str_011(joypad.get()["P2 Up"]))
--  pSetPad["P1 Up"] = true
  pSetPad["P2 Up"] = joypad.get()["P1 Up"]
  pSetPad["P1 Up"] = joypad.get()["P2 Up"]
  joypad.set(pSetPad)
]]  
end

--[[
	用意されてるやつ。
	描画のタイミングで常に実行され続ける。
]]
gui.register(function()
  
  fManReg()
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
    savestate.load(0xFFFF01)
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
--[[  
  for key, val in pairs() do
    if string.find(key,"_",-4,true) == nil then
        print(key, val)
    end
  end
]]
end)

--[[
	用意されてるやつ。
	ロードされたタイミングで呼ばれるファンクション
]]
savestate.registerload(function()
    fLodIni()
end)

--[[
	用意されてるやつ。
	エミュレータ起動時に呼ばれるファンクション
]]
emu.registerstart(function()
    fIni()
end)

--[[
	用意されてるやつ。
ロードが完了する前/セーブされたタイミングで呼ばれるファンクション
]]
savestate.registersave(function()
end)

--[[
	用意されてるやつ。処理後に呼ばれるらしい
]]
emu.registerafter(function()
  pSetPad["P2 Up"] = joypad.get()["P1 Up"]
--  pSetPad["P1 Up"] = joypad.get()["P2 Up"]
  joypad.set(pSetPad)
end)

--[[
	用意されてるやつ。処理前に呼ばれるらしい
]]
emu.registerbefore(function()
  gui.text(30,30,f2Str_011(joypad.get()["P1 Up"]))
--  gui.text(30,40,f2Str_011(joypad.get()["P2 Up"]))

--  pSetPad["P1 Up"] = true

end)

