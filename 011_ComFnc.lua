--[[
	ファイル名:011_ComFnc.lua
	説明:共通関数。簡単なもの。
]]


--型を問わず文字列に変換してプリントさせる
function f2Str_011(prm)
  local lStr
  local tp = type(prm)
  if tp == "boolean" then    
    if prm then
      lStr = "true"
    else
      lStr = "false"
    end  
  elseif tp == "number" then
    lStr = prm .. ""
  elseif tp == "string" then  
    lStr = prm
  else
    lStr = tp
  end
	return lStr
end

function table.dcopy(tbl)
    local orig_type = type(tbl)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, tbl, nil do
            copy[table.dcopy(orig_key)] = table.dcopy(orig_value)
        end
--        setmetatable(copy, table.dcopy(getmetatable(tbl)))
    else -- number, string, boolean, etc
        copy = tbl
    end
    return copy
end
