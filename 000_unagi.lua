print("unagi lua script")

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
local pRegCnt = 0
local pFrmCnt = 0
local pRegisterAfter = 0
local pRegisterBefore = 0
local pRegister = 0

--定数系テーブルオブジェクト
local pMem
local pCon
local pMenLbl
local pConChaNum

--変数系テーブルオブジェクト
local pNowMemSts = {}

--メニューリスト項目
local pMenLstPge
local pMenLstCha
local pMenLstSar
local pMenLstCol
local pMenLstCnt

--メニューリストID
local pIdxPag = 1
local pIdxLstCha1Pl = 1
local pIdxLstSar1Pl = 0
local pIdxLstCol1Pl = 0
local pIdxLstCnt = 1
local pIdxLstCha2Pl = 1
local pIdxLstSar2Pl = 0
local pIdxLstCol2Pl = 0
local pIdxLstStg = 0

--メニューリスト選択中ID 
local pNowLstIdx = {}
local pBefLstIdx = {}
    
local pMenRow = {}     --選択中の項目行
local pMenCol = {}     --選択中の項目列

--メニューリストの値
local pLstVal = {}

--カラー
local pColStrEnb    --文字色：選択可能
local pColStrDis    --文字色：選択不可ラベル
local pColStrAct    --文字色：アクティブ
local pColStrNot    --文字色：注釈
local pColBkg       --背景色
local pColRecEnb    --選択ボックス：有効
local pColRecAct    --選択ボックス:アクティブ

local pGetCnt = 0
local pSetCnt = 0
local pSetFrm = 0
local pSetNonFrm = 0

local p1RightCnt = 0

local pFlgMen = 0     --メニュー画面を描画する指示フラグ
local pFlgMenDisp = 0 --メニュー画面を既に表示しているかどうかのフラグ
local pFlgDbgTxt = 1  --デバッグ用のgui.text表示
local pFlgLng = 0     --言語 0:日本語

local pImgMen         --メニュー画面画像

local pInpJoyPad = {}         --キー入力の受け皿
local pInpJoyCst = {}         --入力されたキー情報の追加情報入力用
local pBefJoyPad = {}         --1フレーム前のキー入力保存用
local pBefJoyCst = {}         --1フレーム前の入力されたキー情報の追加情報入力用

local pSetPad = {}        --キー設定用

local pMenObj = {}  --
local pMenOfx = 0     --メニューのオフセットx座標
local pMenOfy = 0     --メニューのオフセットy座標

local pMenStaUsr = "P1"  --メニューを起動したのが、P1かP2か(joypadオブジェクトで再利用)

local pKeyKeep = {1,21,41,61,81}  --キー押しっぱなしの場合にちょっと反応を引っかける用

local pRelCha1Pl = nil
local pRelSar1Pl = nil
local pRelCol1Pl = nil
local pRelCha2Pl = nil
local pRelSar2Pl = nil
local pRelCol2Pl = nil
local pRelCnt = nil
local pRelStg = nil
local pFlgRel = false
local pRelTimCnt = 0
local pRelTimMax = 60

--[[
	自作関数
  メニュー内のキーおしっぱに対応してちょっと反応を引っかける
]]
function fKeyKeep(frm)
  if frm >= pKeyKeep[#pKeyKeep] then
    return true
  end
  for i = 1 ,#pKeyKeep do
    if frm == pKeyKeep[i] then
      return true
    else
    end
  end
  return false
end

--[[
	自作関数
	メニュー配列のインデックスを加減算して良いかの判定をし
  加減算するか、次のインデックスがnilの場合止める
]]
function fMovCur(rc,flg)
  if rc == 1 and flg == 1 then
    --行を下へ移動する場合
    if pMenObj[pIdxPag][pMenRow[pIdxPag] + 1] == nil then
      --これ以上行が無い場合は止める
    else
      if pMenObj[pIdxPag][pMenRow[pIdxPag] + 1][pMenCol[pIdxPag]] == nil then
        --下へ移動後、カラムが無い場合はその行の最終カラムを選択する
        pMenRow[pIdxPag] = pMenRow[pIdxPag] + 1
        pMenCol[pIdxPag] = #pMenObj[pIdxPag][pMenRow[pIdxPag] + 1]
      else
        pMenRow[pIdxPag] = pMenRow[pIdxPag] + 1
      end
    end
  elseif rc == 1 and flg == 2 then
    --行を上へ移動する場合
    if pMenObj[pIdxPag][pMenRow[pIdxPag] - 1] == nil or pMenRow[pIdxPag] == 1 then
      --これ以上行が無い場合は止める
    else
      if pMenObj[pIdxPag][pMenRow[pIdxPag] - 1][pMenCol[pIdxPag]] == nil then
        --上へ移動後、カラムが無い場合はその行の先頭カラムを選択する
        pMenRow[pIdxPag] = pMenRow[pIdxPag] - 1
        pMenCol[pIdxPag] = 1
      else
        pMenRow[pIdxPag] = pMenRow[pIdxPag] - 1
      end
    end
  elseif rc == 2 and flg == 1 then
    if pMenObj[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag] + 1] == nil then
      --右へ移動 カラムが無い場合は止める
      --nop
    else
      pMenCol[pIdxPag] = pMenCol[pIdxPag] + 1
    end
  elseif rc == 2 and flg == 2 then
    if pMenObj[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag] - 1] == nil then
      --nop
    else
      pMenCol[pIdxPag] = pMenCol[pIdxPag] - 1
    end
  end
end

--[[
	自作関数
	受け取った配列のインデックスを加減算して良いかの判定をし
  加減算するか、次のインデックスがnilの場合逆へ
]]
function fCtlTbl(tbl,idx,flg)
  local residx
  if flg == 1 then
    if tbl[idx + 1] == nil then
      residx = 1
    else
      residx = idx + 1
    end
  elseif flg == 2 then
    if tbl[idx - 1] == nil then
      residx = #tbl
    else
      residx = idx - 1
    end
  end
  return residx
end

--[[
	自作関数
	メニュー操作
]]
function fMenCtl()
  
  for key, val in pairs(pInpJoyCst) do
    --ボタン操作に応じて対象インデックスのオンオフ
    if string.find(key,pMenStaUsr,0,true) ~= nil and string.find(key,"Punch_frm",-9,true) ~= nil and fKeyKeep(val) then
--      print(key)
      --パンチボタンが押されていたら、選択項目のインデックスを1個進める
      pNowLstIdx[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag]].idx = fCtlTbl(pNowLstIdx[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag]], pNowLstIdx[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag]].idx,1)
    elseif string.find(key,pMenStaUsr,0,true) ~= nil and string.find(key,"Kick_frm",-8,true) ~= nil and fKeyKeep(val) then
      --キックボタンが押されていたら、選択項目のインデックスを1個戻す
      pNowLstIdx[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag]].idx = fCtlTbl(pNowLstIdx[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag]], pNowLstIdx[pIdxPag][pMenRow[pIdxPag]][pMenCol[pIdxPag]].idx,2)
    elseif string.find(key,pMenStaUsr,0,true) ~= nil and string.find(key,"Down_frm",-8,true) ~= nil and fKeyKeep(val) then 
      --下キーが押されていたら、一つ上の選択項目へ
       fMovCur(1,1)
    elseif string.find(key,pMenStaUsr,0,true) ~= nil and string.find(key,"Up_frm",-6,true) ~= nil and fKeyKeep(val) then
      --上キーが押されていたら、一つ上の選択項目へ
       fMovCur(1,2)       
    elseif string.find(key,pMenStaUsr,0,true) ~= nil and string.find(key,"Right_frm",-9,true) ~= nil and fKeyKeep(val) then
      --右キーが押されていたら、一つ上の選択項目へ
       fMovCur(2,1)
    elseif string.find(key,pMenStaUsr,0,true) ~= nil and string.find(key,"Left_frm",-8,true) ~= nil and fKeyKeep(val) then
      --左キーが押されていたら、一つ上の選択項目へ
       fMovCur(2,2)       
    end
  end
end

--[[
	自作関数
	時間とキャラの動き、スタン値回復を停止
]]
function fSetStp()
  local lTim = memory.readbyte(pMem.RndTim)
  local lStn1Pl = memory.readbyte(pMem.Stn1Pl)
  local lStn2Pl = memory.readbyte(pMem.Stn2Pl)
  
  memory.writebyte(pMem.RndTim,lTim)  --時間固定
  memory.writebyte(pMem.Stp1pl,0x01)  --1P停止
  memory.writebyte(pMem.Stp2pl,0x01)  --2P停止  
  memory.writebyte(pMem.Stn1Pl,lStn1Pl)  --1Pスタン値自動回復停止
  memory.writebyte(pMem.Stn2Pl,lStn2Pl)  --2Pスタン値自動回復停止
  
end
--[[
	自作関数
	キー情報を無にしてセット
]]
function fSetJoyKeyNon()
	pSetPad["P1 Up"]=false
	pSetPad["P1 Down"]=false
	pSetPad["P1 Left"]=false
	pSetPad["P1 Right"]=false
  
	pSetPad["P1 Weak Punch"]=false
	pSetPad["P1 Medium Punch"]=false
	pSetPad["P1 Strong Punch"]=false

	pSetPad["P1 Weak Kick"]=false
	pSetPad["P1 Medium Kick"]=false
	pSetPad["P1 Strong Kick"]=false

	pSetPad["P1 Coin"]=false
	pSetPad["P1 Start"]=false
  
  pSetPad["P2 Up"]=false
	pSetPad["P2 Down"]=false
	pSetPad["P2 Left"]=false
	pSetPad["P2 Right"]=false
  
  pSetPad["P2 Weak Punch"]=false
	pSetPad["P2 Medium Punch"]=false
	pSetPad["P2 Strong Punch"]=false

	pSetPad["P2 Weak Kick"]=false
	pSetPad["P2 Medium Kick"]=false
	pSetPad["P2 Strong Kick"]=false

	pSetPad["P2 Coin"]=false
	pSetPad["P2 Start"]=false

	pSetPad["Region"]=1
	pSetPad["Reset"]=false
	pSetPad["Service"]=false  
  pSetPad["Diagnostic"]=false

  joypad.set(pSetPad)
end

--[[
	自作関数
	キー情報格納
]]
function fGetJoyKey()
  
  if pInpJoyPad ~= nil then
    --直前フレームのキー入力を保存(配列はそのまま代入しても参照になるので、1個ずつ代入)
    for key, val in pairs(pInpJoyPad) do
      pBefJoyPad[key] = val
    end
  end
  
  if pInpJoyCst ~= nil then
    --直前フレームのキー入力を保存(配列はそのまま代入しても参照になるので、1個ずつ代入)
    for key, val in pairs(pInpJoyCst) do
      pBefJoyCst[key] = val
    end
  end
  
  --今フレームのキー入力を入手
  pInpJoyPad = joypad.get()
  
	--スティック入力判定の取得
	if pInpJoyPad["P1 Down"] and pInpJoyPad["P1 Left"] then
		pInpJoyCst["P1 Stick"] = 1
	elseif pInpJoyPad["P1 Down"] and pInpJoyPad["P1 Right"] then
		pInpJoyCst["P1 Stick"] = 3
	elseif pInpJoyPad["P1 Down"] then
		pInpJoyCst["P1 Stick"] = 2
	elseif pInpJoyPad["P1 Up"] and pInpJoyPad["P1 Left"] then
		pInpJoyCst["P1 Stick"] = 7
	elseif pInpJoyPad["P1 Up"] and pInpJoyPad["P1 Right"] then
		pInpJoyCst["P1 Stick"] = 9
	elseif pInpJoyPad["P1 Up"] then
		pInpJoyCst["P1 Stick"] = 8
	elseif pInpJoyPad["P1 Left"] then
		pInpJoyCst["P1 Stick"] = 4
	elseif pInpJoyPad["P1 Right"] then
		pInpJoyCst["P1 Stick"] = 6
	else
		pInpJoyCst["P1 Stick"] = 5
	end

  --追加情報の付与(何フレーム押されたかと、離された時)
  for key, val in pairs(pInpJoyPad) do        
    --連続で押されたキーのフレーム数を加算
    if pBefJoyPad[key] == true and pInpJoyPad[key] == true then
      pInpJoyCst[key.."_frm"] = pBefJoyCst[key.."_frm"] + 1
    else
      pInpJoyCst[key.."_frm"] = 0
    end
    
    --キーが離された場合にフラグを立てる
    --[[
ボタンを押したらメニューを表示
⇒その後ボタンを離されてから、次にボタンを押されるまではメニューを閉じない
    ]]
    if pBefJoyPad[key] == true and pInpJoyPad[key] == false then
      pInpJoyCst[key.."_dis"] = 1
    else
      pInpJoyCst[key.."_dis"] = 0
    end
  end
  
  for key, val in pairs(pInpJoyPad) do        
    if val == true then
      print("UP1 " .. key .. " : " .. f2Str_011(val))
    end
  end


  fChgCnt()
  
--[[
  i = 0
  for key, val in pairs(pInpJoyPad) do
    if string.find(key," ",3,true) ~= nil then
      gui.text(30,i,key .. " : " .. f2Str_011(val))
      i = i + 8
      if val == true then
        print(key)
      end
    end
  end
  
  i = 0
  for key, val in pairs(joypad.get()) do
    if string.find(key," ",3,true) ~= nil then
      gui.text(130,i,key .. " : " .. f2Str_011(val))
      i = i + 8
    end
  end
  
  i = 0
  for key, val in pairs(pInpJoyCst) do
    if string.find(key," ",3,true) ~= nil then
      gui.text(230,i,key .. " : " .. f2Str_011(val))
      i = i + 8
    end
  end
]]  
  
--  fChgCnt()
end

--[[
	自作関数
	メニューオブジェクトの定義
    これで作った配列をブン回せば勝手にメニュー画面が出来るはず・・
  
  方針
  ラベル部分とカーソルが移動する選択可能文字列は配列ごと分ける。
  配列の添え字でカーソル位置を決めるため
  
  いろいろ考えたけども
  
  添え字0で始まるのはただのラベル
  k : 1:タイトル, 2:ラベル(選択不可文字列), 3:注釈
  と、kの値でフォントの種類などを調整する
  
  添え字1以上は座標を表している
  選択可能文字列を等ファンクションで生成。
  sx,sy,ex,ey は矩形描画用で、アクティブ時にはこれを描画する。
  
]]
function fSetMenObj(page)
  local lVal
  lVal = {}

  if page == 1 then

    lVal[0] = {}
    lVal[0][1] = {l = "キャラ、ステージ設定", k = 1,                  x = 10,   y = 40}
    lVal[0][2] = {l = "1P", k = 2,                                    x = 10,   y = 80}
    lVal[0][3] = {l = "2P", k = 2,                                    x = 10,   y = 100}
    lVal[0][4] = {l = "キャラ", k = 2,                                x = 30,   y = 65}
    lVal[0][5] = {l = "SA", k = 2,                                    x = 90,   y = 65}
    lVal[0][6] = {l = "カラー", k = 2,                                x = 160,  y = 65}
    lVal[0][7] = {l = "自分の操作", k = 2,                                  x = 30,   y = 125}
    lVal[0][8] = {l = "ステージ＆BGM", k = 2,                         x = 30,   y = 165}
    lVal[0][9] = {l = "P:進む(>) / K:戻る(<) / S:ゲームに戻る", k = 3,        x = 5,   y = 220}
    lVal[0][10] = {l = "※ギル(GI)と真豪鬼(GO*)は挙動がおかしい部分があります", k = 3,        x = 5,   y = 208}
    
    lVal[1] = {}
    lVal[1][1] = {l = "< " .. pNowLstIdx[1][1][1][pNowLstIdx[1][1][1].idx] .. " >",                           x = 5,   y = 15}
    
    lVal[2] = {}
    lVal[2][1] = {l = "< " .. pNowLstIdx[1][2][1][pNowLstIdx[1][2][1].idx] .. " >",  x = 30,   y = 80}
    lVal[2][2] = {l = "< " .. pNowLstIdx[1][2][2][pNowLstIdx[1][2][2].idx] .. " >",  x = 90,   y = 80}
    lVal[2][3] = {l = "< " .. pNowLstIdx[1][2][3][pNowLstIdx[1][2][3].idx] .. " >",  x = 160,  y = 80}
    
    lVal[3] = {}
    lVal[3][1] = {l = "< " .. pNowLstIdx[1][3][1][pNowLstIdx[1][3][1].idx] .. " >",  x = 30,   y = 100}
    lVal[3][2] = {l = "< " .. pNowLstIdx[1][3][2][pNowLstIdx[1][3][2].idx] .. " >",  x = 90,   y = 100}
    lVal[3][3] = {l = "< " .. pNowLstIdx[1][3][3][pNowLstIdx[1][3][3].idx] .. " >",  x = 160,  y = 100}
    
    lVal[4] = {}
    lVal[4][1] = {l = "< " .. pNowLstIdx[1][4][1][pNowLstIdx[1][4][1].idx] .. " >",  x = 30,  y = 140}
    
    lVal[5] = {}
    lVal[5][1] = {l = "< " .. pNowLstIdx[1][5][1][pNowLstIdx[1][5][1].idx] .. " >",  x = 30,  y = 180}
  elseif page == 2 then
  elseif page == 3 then
  elseif page == 4 then
  elseif page == 5 then
  end

  return lVal
end

--[[
	自作関数
  メニューの描画
  変更可能な項目を色で分け、現在選択中の項目を点滅させる方式で
]]
function fDrwMenP1(page)
  local key,val
  local lColStr,lColRec,lFntNam,lFntPnt
  local x, y = pImgMen:sizeXY()
  
  pImgMen:filledRectangle(0, 0, x, y, pColBkg)
--  local 
  for i = 0 , #pMenObj[page] do
    for j = 1 , #pMenObj[page][i] do
      
      --文字色、フォント
      if i == 0 and pMenObj[page][i][j].k == 1 then
        --タイトル
        lFntNam, lFntPnt, lColStr = pCon.TitFntNam, pCon.TitFntPnt, pColStrDis
      elseif i == 0 and pMenObj[page][i][j].k == 2 then
        --ラベル
        lFntNam, lFntPnt, lColStr = pCon.MenFntNam, pCon.MenFntPnt, pColStrDis
      elseif i == 0 and pMenObj[page][i][j].k == 3 then
        --注釈
        lFntNam, lFntPnt, lColStr = pCon.NotFntNam, pCon.NotFntPnt, pColStrNot
      elseif pMenRow[page] == i and pMenCol[page] == j and i >= 1 and pNowFrm % 40 >= 20 then
        --現在選択項目 1～20フレームまで
        lFntNam, lFntPnt, lColStr = pCon.MenFntNam, pCon.MenFntPnt, pColStrAct
      elseif pMenRow[page] == i and pMenCol[page] == j and i >= 1 and pNowFrm % 40 < 20 then
        --現在選択項目 21～40フレームまで
        lFntNam, lFntPnt, lColStr = pCon.MenFntNam, pCon.MenFntPnt, pColStrEnb
      elseif i >= 1 then
        --選択可能項目
        lFntNam, lFntPnt, lColStr = pCon.MenFntNam, pCon.MenFntPnt, pColStrEnb
      end    
             
      --文字の描画
      pImgMen:stringFT(lColStr, lFntNam, lFntPnt, 0, pMenOfx + pMenObj[page][i][j].x, pMenOfy + pMenObj[page][i][j].y, pMenObj[page][i][j].l)
    end
  end
end

--[[
	自作関数
	毎フレーム効かせるチート
]]
function fCht()
  
  --シチュエーション変更
  if pFlgRel == true then
    memory.writebyte(pMem.SelCha1Pl,pRelCha1Pl)
    memory.writebyte(pMem.SelSar1Pl,pRelSar1Pl)
    memory.writebyte(pMem.SelCol1Pl,pRelCol1Pl)
    memory.writebyte(pMem.SelCha2Pl,pRelCha2Pl)
    memory.writebyte(pMem.SelSar2Pl,pRelSar2Pl)
    memory.writebyte(pMem.SelCol2Pl,pRelCol2Pl)
    memory.writebyte(pMem.SelStg,pRelStg)
  end
  
  memory.writebyte(pMem.RndTim,0x64)  --時間MAX
--  memory.writebyte(pMem.SelCha1Pl,0x0F)  --
--  memory.writebyte(pMem.SelCha2Pl,0x00)  --
--  memory.writebyte(pMem.SelSar1Pl,0x02)  --
--  memory.writebyte(pMem.SelSar2Pl,0x01)  --
--  memory.writebyte(pMem.SelCol1Pl,0x03)  --
--  memory.writebyte(pMem.SelCol2Pl,0x04)  --
--  memory.writebyte(pMem.SelStg,0x10)  --
--  memory.writebyte(pMem.Vit1Pl,0x00)

--[[  
  if pFlgMen == 1 then
    --メニューフラグが立っている場合は、体力MAXにしておく
    memory.writebyte(pMem.Vit1Pl,0xA0)
    memory.writebyte(pMem.Vit2Pl,0xA0)
  end
]]
--今のセーブステート6がいい感じ
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
  
  pMenObj[1] = fSetMenObj(1)
  pMenObj[2] = fSetMenObj(2)
  pMenObj[3] = fSetMenObj(3)
  pMenObj[4] = fSetMenObj(4)
  pMenObj[5] = fSetMenObj(5)
end

--[[
	自作関数
	lua有効時の変数の初期化
]]
function fIni()
  --フレーム制御用
  pFrmCnt = 0
  
  --定数
  pMem = fMemAdrSet_010()
  pCon = fConValSet_010()
  if pFlgLng == 0 then
    pMenLstPge = fMenLstPgeJpn_010()
    pMenLbl = fMenLblJpn_010()
    pMenLstCha = fMenLstChaJpn_010()
  end

  pMenLstSar = fMenLstSar_010()
  pMenLstCol = fMenLstCol_010()
  pMenLstCnt = fMenLstCnt_010()
  pConChaNum = fConChaNum_010()

  --メニュー画像用
  pImgMen = gd.createTrueColor(385, 225)
  pColStrDis = pImgMen:colorAllocate(200, 200, 200) 
  pColStrEnb = pImgMen:colorAllocate(0xF0, 0xE6, 0x8C) 
  pColStrAct = pImgMen:colorAllocate(0xB2, 0x22, 0x22)
  pColStrNot = pImgMen:colorAllocate(0xBA, 0x55, 0xD3)
--  pColBkg = pImgMen:colorAllocate(58, 58, 58)
  pColBkg = pImgMen:colorAllocate(0x2F, 0x4F, 0x4F)
  pColRecEnb = pImgMen:colorAllocate(255, 255, 255)
  pColRecAct = pImgMen:colorAllocate(255, 0, 0)


  --キー入力捕捉
  fGetJoyKey()
--  pSetPad = joypad.get()
  
  --メニュー選択用IDテーブルの初期化
--  for key in pairs(pMenObj[1]) do
--    pNowLstIdx[key] = 
--  end

  pNowLstIdx[1] = {}
  
    --ページ1
    pNowLstIdx[1][1] = {}
--    pNowLstIdx[1][1][1] = 1    --ページ
    pNowLstIdx[1][1][1] = fMenLstPgeJpn_010()    --ページ
    pNowLstIdx[1][2] = {}
--    pNowLstIdx[1][2][1] = 1    --1Pキャラ
    pNowLstIdx[1][2][1] = fMenLstChaJpn_010()    --1Pキャラ
--    pNowLstIdx[1][2][2] = 1    --1PSA
    pNowLstIdx[1][2][2] = fMenLstSar_010()    --1PSA
--    pNowLstIdx[1][2][3] = 1    --1Pカラー
    pNowLstIdx[1][2][3] = fMenLstCol_010()    --1Pカラー
    pNowLstIdx[1][3] = {}
    pNowLstIdx[1][3][1] = fMenLstChaJpn_010()    --2Pキャラ
    pNowLstIdx[1][3][2] = fMenLstSar_010()    --2PSA
    pNowLstIdx[1][3][3] = fMenLstCol_010()    --2Pカラー
    pNowLstIdx[1][4] = {}
    pNowLstIdx[1][4][1] = fMenLstCnt_010()    --自分の操作
    pNowLstIdx[1][5] = {}
    pNowLstIdx[1][5][1] = fMenLstChaJpn_010()    --ステージ＆BGM
    
  pNowLstIdx[2] = {}
    --ページ2

  pNowLstIdx[3] = {}
    --ページ3

  pNowLstIdx[4] = {}
    --ページ4
    
  pNowLstIdx[5] = {}
    --ページ5
    
  --メニュー選択項目の初期化
  for i = 1 , #pNowLstIdx do
    pMenRow[i] = 1
    pMenCol[i] = 1
  end

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
  
  if pFlgDbgTxt == 1 then
    fGuiTxt()
  end

  --メニュー表示フラグがONの場合、メニューを描画
  if pFlgMen == 1 then
    
    fDrwMenP1(1)
    
    --メニュー画面表示
    gui.image(0,0,pImgMen:gdStr())
    pFlgMenDisp = 1
  elseif pFlgMen == 0 then
    pFlgMenDisp = 0
    gui.clearuncommitted()
  end
  
  --リロード中は画面を塗りつぶしておく
  if pFlgRel == true then
    local x, y = pImgMen:sizeXY()
  
    pImgMen:filledRectangle(0, 0, x, y, pColBkg)    
    gui.image(0,0,pImgMen:gdStr())
  end
  
  --コントローラ交換
  if pRelCnt == 2 then
--    fChgCnt()
  end
  
--  pSetPad["P2 Up"]=true
--  joypad.set(pSetPad)
  
end
--[[
	自作関数
	1フレーム毎に呼ばれる処理
]]
function fFrm()
  pFrmCnt = pFrmCnt + 1
	
  --メニューで指示されたチートを実行
	fCht()
  
  --リロード
  if pFlgRel == true and pRelTimCnt == 0 then
    pRelTimCnt = pRelTimCnt + 1
    savestate.load(0xFFFF01)
  elseif pFlgRel == true and pRelTimCnt == pRelTimMax then  
    pRelTimCnt = 0
    pFlgRel = false
  elseif pFlgRel == true and pRelTimCnt > 0 then  
    pRelTimCnt = pRelTimCnt + 1
  end  
  
  --メモリ情報取得
  local key, val
  for key, val in pairs(pMem) do
    pNowMemSts[key] = memory.readbyte(val)
  end
  
  --キー入力情報の取得
  fGetJoyKey()
  
  --1Pか2Pのスタートボタンを検知した場合は、メニュー表示/非表示切り替え
  if pInpJoyCst["P1 Start_dis"] == 1 and pFlgMenDisp == 0 then
    --メニューを起動する(P1)
    pFlgMen = 1
    pMenStaUsr = "P1"
    
    --メニュー起動時の変数
    fMenOpn()

  elseif pInpJoyCst["P2 Start_dis"] == 1 and pFlgMenDisp == 0 then
    --メニューを起動する(P2)(同フレームの場合はP1が優先)
    pFlgMen = 1
    pMenStaUsr = "P2"
  
    --メニュー起動時の変数
    fMenOpn()
  
  elseif pInpJoyCst["P1 Start_dis"] == 1 and pMenStaUsr == "P1" and pFlgMenDisp == 1 then
    --メニューを閉じる場合は、変更箇所の処理に応じた処理を実施
    --メニュー起動フラグをオフに
    pFlgMen = 0
    pFlgMenDisp = 0
    
    --メニューを閉じる際の処理
    fMenCls()
    
  elseif pInpJoyCst["P2 Start_dis"] == 1 and pMenStaUsr == "P2" and pFlgMenDisp == 1 then
    --メニューを閉じる場合は、変更箇所の処理に応じた処理を実施
    --メニュー起動フラグをオフに
    pFlgMen = 0
    pFlgMenDisp = 0
    
    --メニューを閉じる際の処理
    fMenCls()
    
  else
    
  end

  if pFlgMen == 1 then
    --メニュー起動フラグが立っていればキャラクターの動きと時間を停止
    fSetStp()
  end
  
  if pFlgMenDisp == 1 then
    --既にメニューを表示している場合
    --キー入力から情報を取得してメニュー操作
    fMenCtl()
    
    --メニューオブジェクト情報を再設定
    pMenObj[1] = fSetMenObj(1)
  else
  
  end

  --コントローラ交換
--  if pRelCnt == 2 then
--    fChgCnt()
--  end

end

--[[
	自作関数
	メニューを閉じる瞬間のフラグ立てなど
]]
function fMenCls()
  pFlgRel = false

  --1ページ目は何か変わってたらロードするフラグを立てる
  if pNowLstIdx[1][2][1].idx ~= pBefLstIdx[1][2][1].idx
   or pNowLstIdx[1][2][1].idx ~= pBefLstIdx[1][2][1].idx
   or pNowLstIdx[1][2][3].idx ~= pBefLstIdx[1][2][3].idx
   or pNowLstIdx[1][3][1].idx ~= pBefLstIdx[1][3][1].idx
   or pNowLstIdx[1][3][2].idx ~= pBefLstIdx[1][3][2].idx
   or pNowLstIdx[1][3][3].idx ~= pBefLstIdx[1][3][3].idx
   or pNowLstIdx[1][4][1].idx ~= pBefLstIdx[1][4][1].idx
   or pNowLstIdx[1][5][1].idx ~= pBefLstIdx[1][5][1].idx then
  
    pRelCha1Pl = pNowLstIdx[1][2][1].idx - 1
    pRelSar1Pl = pNowLstIdx[1][2][2].idx - 1
    pRelCol1Pl = pNowLstIdx[1][2][3].idx - 1
    pRelCha2Pl = pNowLstIdx[1][3][1].idx - 1
    pRelSar2Pl = pNowLstIdx[1][3][2].idx - 1
    pRelCol2Pl = pNowLstIdx[1][3][3].idx - 1
    pRelCnt = pNowLstIdx[1][4][1].idx
    pRelStg = pNowLstIdx[1][5][1].idx - 1
    pFlgRel = true  
  end
  
  --
  
end

--[[
	自作関数
	メニューを開く瞬間のフレーム処理
]]
function fMenOpn()
  --メニューを開く場合の処理
  --キャラ、ステージの選択情報などをメモリから取得
  --ゲーム上のメモリパラメータは大抵ゼロ始まりだがluaの配列添え字が1始まりなので、+1で調整
  pNowLstIdx[1][2][1].idx = pNowMemSts.SelCha1Pl + 1
  pNowLstIdx[1][2][2].idx = pNowMemSts.SelSar1Pl + 1
  pNowLstIdx[1][2][3].idx = pNowMemSts.SelCol1Pl + 1    
  pNowLstIdx[1][3][1].idx = pNowMemSts.SelCha2Pl + 1
  pNowLstIdx[1][3][2].idx = pNowMemSts.SelSar2Pl + 1
  pNowLstIdx[1][3][3].idx = pNowMemSts.SelCol2Pl + 1
  pNowLstIdx[1][5][1].idx = pNowMemSts.SelStg + 1
  
  --メニューを開いた時のインデックス状態を記憶
  pBefLstIdx = table.dcopy(pNowLstIdx)    
end

--[[
]]
function fChgCnt()
  local lSetJoyPad = {}
  local pl1,pl2 = "P1 ", "P2 "
  local joykey,pl
  local i = 0
  
  for key, val in pairs(pInpJoyPad) do        
    --
    if string.find(key," ",3,true) ~= nil then
      pl = string.sub(key, 1, 3)
      joykey = string.sub(key, 4)
            
      if pl == pl1 then
        lSetJoyPad[pl2 .. joykey] = val
      elseif pl == pl2 then
        lSetJoyPad[pl1 .. joykey] = val
      end
    end
 --   if val == true then
 --     print("UP " .. key .. " : " .. f2Str_011(val))
 --   end
  end

  i = 0
  for key, val in pairs(lSetJoyPad) do
    if string.find(key," ",3,true) ~= nil then
--      gui.text(30,i,key .. " : " .. f2Str_011(val))
      i = i + 8
    end
  end
  
  for key, val in pairs(lSetJoyPad) do        
    if val == true then
      print("UP2 " .. key .. " : " .. f2Str_011(val))
    end
  end
  
  for key, val in pairs(pInpJoyPad) do        
    if val == true then
      print("UP3 " .. key .. " : " .. f2Str_011(val))
    end
  end
  
--  joypad.set(lSetJoyPad)
  
end


--[[
	自作関数
	調査をする上で、複数の値を常に表示しておきたい場合に使う
	例えば、メモリサーチをうんたん
]]
function fGuiTxt()
--[[  
  gui.text(30,30,"emu.framecount : " .. emu.framecount())
  gui.text(30,40,"pFrmCnt : " .. pFrmCnt)
  gui.text(30,50,"pNowFrm : " .. pNowFrm)
--  gui.text(30,60,"pRegisterAfter : " .. pRegsterAfter)
  gui.text(30,70,"pGetCnt : " .. pGetCnt)
  gui.text(30,80,"pSetCnt : " .. pSetCnt)
  gui.text(30,90,"pSetFrm : " .. pSetFrm)
  gui.text(30,100,"pSetNonFrm : " .. pSetNonFrm)
  ]]
--  gui.text(30,50,"0x020154A6 byte : " .. memory.readbyte(pMem.GamMod1))
--  gui.text(30,60,"0x020154A7 byte : " .. memory.readbyte(pMem.GamMod2))
--  gui.text(30,70,"0x020154A6 word : " .. memory.readword(pMem.GamMod1))
--  gui.text(30,80,"0x020154A7 word : " .. memory.readword(pMem.GamMod2))
--  gui.text(30,110,"pInpJoyPad[\"P1 Up\"] : " .. fBln2Str_011(pInpJoyPad["P1 Up"]))
--  gui.text(30,120,"pSetPad[\"P1 Up\"] : " .. fBln2Str_011(pSetPad["P1 Up"]))  
--  gui.text(30,130,"pFlgMen : " .. pFlgMen)
end

--[[
	用意されてるやつ。
	描画のタイミングで常に実行され続ける。
]]
gui.register(function()
          
  pRegister = pRegister + 1
  fManReg()
end)

--[[
	用意されてるやつ。
	ホットキー1を押される度に動作するファンクション
]]
input.registerhotkey(1, function()
  local test = "P2 Weak Kick"
  print(string.sub(test,1,3))
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
    print("pRegister : " .. pRegister)
    print("pRegisterAfter : " .. pRegisterAfter)
    print("pRegisterBefore : " .. pRegisterBefore)
    print("pFrmCnt : " .. pFrmCnt)
end)

--[[
	用意されてるやつ。
	ホットキー4を押される度に動作するファンクション
]]
input.registerhotkey(4, function()
  print(type(true))
end)

--[[
	用意されてるやつ。
	ホットキー5を押される度に動作するファンクション
]]
input.registerhotkey(5, function()
  for key, val in pairs(pInpJoyPad) do
    if string.find(key,"_",-4,true) == nil then
        print(key, val)
    end
  end

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
    pRegisterAfter = pRegisterAfter + 1
    
    --キー入力情報の取得
--    fGetJoyKey()
    
    

end)

--[[
	用意されてるやつ。処理前に呼ばれるらしい
]]
emu.registerbefore(function()
  pRegisterBefore = pRegisterBefore + 1

  
--  if pInpJoyPad["P1 Left"] then
--    pSetPad["P1 Right"] = true
--    joypad.set(pSetPad)
--  end 

--  if pFlgMen == 1 then
--    --メニュー画面が有効な場合は、キー入力をゲーム側に渡さない
--    fSetJoyKeyNon()
--  end

end)
