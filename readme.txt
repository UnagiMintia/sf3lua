unagi.luaの使い方

※unagi.luaはFBA-rr v0.0.7で動作確認をしています。

１．ダウンロード
・FBA-rr v0.0.7を入手
・LuaForWindows_v5.1.4-46を入手
・lua-gd-2.0.33r2を入手

２．配置
・LuaForWindowsをインストール
・FBA,lua-gdを任意のフォルダに解凍
・3rdのROMをsfiii3.zipにリネームして、FBA-rr-v007\roms\ に配置

３．環境変数の追加
システム環境変数に下記を追加
LUA_CPATH=;;【lua-gdを解凍したフォルダ】\?.dll

例)
C:\SFData\lua-gd-2.0.33r2 に解凍している場合
LUA_CPATH=;;C:\SFData\lua-gd-2.0.33r2\?.dll

４．起動
FBAを起動して、unagi.lua をドラッグアンドドロップするか、
Game>Lua Scripting>New Lua Scripting Window から、unagi.luaを指定



