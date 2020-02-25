--[[
	ファイル名:010_PrmSet.lua
	説明:各種パラメータやアドレスなどの定数をセットする。基本的にテーブルに入れて受け渡す。
]]

--メモリアドレス格納用
function 010_fMemAdrSet()
	local lMem
		lMem = {
			--特に断りが無ければ対戦中。対戦中以外は全然違う可能性もある。
			RndTim				= 0x02011377,	--ラウンドの残り時間カウント max 0x64

			Vit1Pl				= 0x02068D0B,	--1P体力 max 0xA0 根性値スタートラインは0x30
			Vit2Pl				= 0x020691A3,	--2P体力

			Stn1Pl				= 0x020695FD,	--1Pスタン値 maxはキャラに依存 72(0x48) 64(0x40) 56(0x38) の3通り
			Stn2Pl				= 0x02069611,	--2Pスタン値

			Cmb1Pl				= 0x020696C5,	--1P?コンボ回数 2Pも別にあるのかな？

			Bgh1Pl				= 0x02026335,	--1P地上上段ブロッキング受付残りフレーム 通常max 0x0A
			Bgh2Pl				= 0x0202673B,	--2P地上上段ブロッキング受付残りフレーム 通常max 0x0A

			Bgl1Pl				= 0x02026337,	--1P地上下段ブロッキング受付残りフレーム 通常max 0x0A
			Bgl2Pl				= 0x0202673D,	--2P地上下段ブロッキング受付残りフレーム 通常max 0x0A

			Baa1Pl				= 0x02026347,	--1P地上空中ブロッキング受付残りフレーム 通常max 0x07
			Baa2Pl				= 0x0202673F,	--2P地上空中ブロッキング受付残りフレーム 通常max 0x07

			Bag1Pl				= 0x02026339,	--1P地上対空ブロッキング受付残りフレーム 通常max 0x05
			Bag2Pl				= 0x0202674D,	--2P地上対空ブロッキング受付残りフレーム 通常max 0x05

			Grp1Pl				= 0x02026328,	--1Pグラップディフェンス 1で有効
			Grp2Pl				= 0x02026328,	--2Pグラップディフェンス 1で有効

			Dir1Pl				= 0x02068C77,	--1Pの向き
			Dir2Pl				= 0x0206910F,	--2Pの向き

			PadIna1Pl			= 0x0202564B,	--キー・ボタン入力をビットで管理 (上,下,左,右,lp,mp,hp の順)
			PadInb1Pl			= 0x0202564A,	--(lk,mk,hk の順 たぶんスタートボタンとか、コインとかも)
			PadIna2Pl			= 0x0202568F,	--joypad.getとjoypad.setでコントロールできるのでメモリから読み取る必要は無い？メモリのが早いのかな？
			PadInb2Pl			= 0x0202568E,	--

			SelCha1Pl			= 0x02011387,	--現在の1Pキャラクター 00:GI 01:AL 02:RY 03:YU 04:DU 05:NE 06:HU 07:IB 08:EL 09:OR 0A:YA
			SelCha2Pl			= 0x02011388,	--現在の2Pキャラクター 0B:KE 0C:SE 0D:UR 0E:GO 0F:GO(没：真豪鬼) 10:CH 11:MA 12:Q  13:TW 14:RE

			SelSar1Pl			= 0x0201138B,	--選択されたSA 0,1,2 がそれぞれSA1,2,3
			SelSar2Pl			= 0x0201138C,	--

			SelCol1Pl			= 0x02015683,	--1Pカラー 0:LP,1:MP,2:HP,3:LK,4:MK:,5:HK,6:LP+MK+HP
			SelCol2Pl			= 0x02015684,	--2Pカラー

			--未確認(Cubeさんのに書いてあったの

--[[

	--2Pが常に屈食らいに
	--memory.writebyte(0x02069312,0x10)


	トレーニングモード用のチート。スタートボタンがおされていて、トレーニングモードカウントとやらが0ではない場合にチート
	if startButton == 1 then
		if trainingModeCount == 0 then
			trainingModeCount = 20
		else
			memory.writebyte(0x02011377,0x64)		--ラウンドタイムマックス
			memory.writebyte(0x02011379,0x00)		--？
			memory.writebyte(0x02010D61,0x00)		--コンボダメージ？
			memory.writebyte(0x020691A3,0xA0)		--2P体力
			memory.writebyte(0x02069611,0x00)		--2Pスタン値
			memory.writebyte(0x02069612,0x00)		--？
			if stunMax == 1 then
				memory.writebyte(0x02069611,0xFF)	--2Pスタン値
			end
		end
	end


			Dmg1Pl				= 0x02010D61,	--コンボダメージ
			GamMod				= 0x020154A7,	--試合中かどうかの分岐に使う？ここの値が 1,2,6,3,8,9 のいずれかであったら試合中 というif文がある。以下みたいなのもある
	game_phase = memory.readword(0x020154A6)
	if game_phase ~= GAME_PHASE_PLAYING 
		and game_phase ~= 6
		and game_phase ~= 3
		and game_phase ~= 7
		and game_phase ~= 8 then
		if new_combo_flg == 0 then
			savestate.load(savestate.create(trialChara*1000+trialNum+1))
			timeInMode2 = 0
		end
	end



			PadSta1Pl			= 0x0206AA8C,	--スタートボタンが押されているかどうかの判定に使っている。これが16だったらスタートボタンが押されていると判定している。恐らく1P
			SelSar1PlAno		= 0x020154D3,	--1Pの選択SAを読み取って判定している。上にあるものとは別アドレス
			DenJinLev			= 0x02068D2D,	--電刃のためレベルらしい(3,9,14,19 でif分岐しているが詳細不明)
			AirCmb				= 0x020694C7,	--空中コンボ追撃時間。これを 0xFFにすると無限になるらしい。削減値のことかな？
				= 0x0206914B,	--2Pが被ダメージ中かどうかを判定。0x00より大きければ被ダメージ中らしい
				= 0x02069149,	--2Pのヒットストップを増大させる？ここに0x80を書き込むことでヒットストップを伸ばしている模様

0x020694C9	--削減値？
0x020694C7



0x02025731	--ブロッキング受付不可時間？
			if BLView == 1 then
			
				--write(0x02026335,0x0A,1)
				--write(0x02026337,0x0A,1)
				--ブロ受付時間表示
				BLY = 50
				BLoffsetY = 6
				gui.drawtext(18,BLY-1,"FRONT")
				yokoGauge2(nil, 40, BLY, 40, 4, memory.readbyte(0x02026335), 10, 0, 0x00C0FFFF)
				if memory.readbyte(0x02025731) ~= 0xFF then
					yokoGauge2(nil, 40, BLY+BLoffsetY, 84, 4, memory.readbyte(0x02025731), 21, 0, 0xFF8000FF)
				else
					yokoGauge2(nil, 40, BLY+BLoffsetY, 84, 4, -1, 21, 0, 0xFF800000)
				end
				
				gui.drawtext(14,BLY-1+BLoffsetY*3,"BOTTOM")
				yokoGauge2(nil, 40, BLY+BLoffsetY*3, 40, 4, memory.readbyte(0x02026337), 10, 0, 0x00C0FFFF)
				if memory.readbyte(0x0202574D) ~= 0xFF then
					yokoGauge2(nil, 40, BLY+BLoffsetY*4, 84, 4, memory.readbyte(0x0202574D), 21, 0, 0xFF8000FF)
				else
					yokoGauge2(nil, 40, BLY+BLoffsetY*4, 84, 4, -1, 21, 0, 0xFF800000)
				end
				
				gui.drawtext(26,BLY-1+BLoffsetY*6,"AIR")
				yokoGauge2(nil, 40, BLY+BLoffsetY*6, 28, 4, memory.readbyte(0x02026339), 7, 0, 0x00C0FFFF)
				if memory.readbyte(0x02025769) ~= 0xFF then
					yokoGauge2(nil, 40, BLY+BLoffsetY*7, 72, 4, memory.readbyte(0x02025769), 18, 0, 0xFF8000FF)
				else
					yokoGauge2(nil, 40, BLY+BLoffsetY*7, 72, 4, -1, 18, 0, 0xFF800000)
				end
				
				gui.drawtext(5,BLY-1+BLoffsetY*9,"ANTI-AIR")
				yokoGauge2(nil, 40, BLY+BLoffsetY*9, 20, 4, memory.readbyte(0x02026347), 5, 0, 0x00C0FFFF)
				if memory.readbyte(0x0202582D) ~= 0xFF then
					yokoGauge2(nil, 40, BLY+BLoffsetY*10, 64, 4, memory.readbyte(0x0202582D), 16, 0, 0xFF8000FF)
				else
					yokoGauge2(nil, 40, BLY+BLoffsetY*10, 64, 4, -1, 16, 0, 0xFF800000)
				end
				
			end


			Sag1Pl				= 0x020286AD,	--1P選択中のSAゲージバーの長さ？、本数？下記のようにすると両プレイヤーのゲージがMAXに。たぶんSAのゲージ長さ、本数がそれぞれ違うのでいろんなアドレスに書き込まないといけない模様

			

	--1Pゲージ
	gauge = memory.readbyte(0x020286AD)
	memory.writebyte(0x02028695,0xFF)
	memory.writebyte(0x020695B5,0xFF)
	memory.writebyte(0x020286AB,gauge)
	memory.writebyte(0x020695BF,gauge)
	memory.writebyte(0x020695BD,gauge)

	--2Pゲージ
	gauge2 = memory.readbyte(0x020286E1)
	memory.writebyte(0x020695E1,0xFF)
	memory.writebyte(0x020286DF,gauge2)
	memory.writebyte(0x0206940D,gauge2)
	memory.writebyte(0x020695EB,gauge2)

	ゲージをMAXにしたいだけなら下記のチートでも出来る。アドレス近いが・・？
	:sfiii3n:00100000:020695BA:00000003:0000FFFF:1PＳＡMAX
	:sfiii3n:00310000:020695BC:00030003:FFFFFFFF:1PＳＡMAX (2/2)
	:sfiii3n:00100000:020695E6:00000003:0000FFFF:2PＳＡMAX
	:sfiii3n:00310000:020695E8:00030003:FFFFFFFF:2PＳＡMAX (2/2)

]]
		}
	return lMem
end

