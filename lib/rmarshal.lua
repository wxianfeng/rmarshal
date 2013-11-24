local bit = require("bit")
local bor = bit.bor
local lshift = bit.lshift
local error = error
local insert = table.insert

-- module(...)

local Marshal = {}

_VERSION = "0.1"

local _load

local function _load_fixnum(s, i)
  local n = s:byte(i)
  if n==0 then return 0, i+1 end
  if n>4 then
    if n<128 then return n-5, i+1 end
    if n<252 then return n-251, i+1 end
  end
  if n==1 then return s:byte(i+1), i+2 end
  if n==255 then return 256-s:byte(i+1), i+2 end
  if n==2 then
    local b0, b1 = s:byte(i+1, i+2)
    return bor(b0, lshift(b1, 8)), i+3
  end
  if n==254 then
    local b0, b1 = s:byte(i+1, i+2)
    return bor(b0, lshift(b1, 8), 0xffff0000), i+3
  end
  if n==3 then
    local b0, b1, b2 = s:byte(i+1, i+3)
    return bor(b0, lshift(b1, 8), lshift(b2, 16)), i+4
  end
  if n==253 then
    local b0, b1, b2 = s:byte(i+1, i+3)
    return bor(b0, lshift(b1, 8), lshift(b2, 16), 0xff000000), i+4
  end
  local b0, b1, b2, b3 = s:byte(i+1, i+4)
  return bor(b0, lshift(b1, 8), lshift(b2, 16), lshift(b3, 24)), i+5
end

local function _load_bignum(s, i)
  local sign = s:byte(i)
  local shortlen, pos = _load_fixnum(s, i+1)
  if shortlen ~= 2 then error("unsupported bignum") end
  local b0, b1, b2, b3 = s:byte(pos, pos+3)
  local v = bor(b0, lshift(b1, 8), lshift(b2, 16), lshift(b3, 24))
  if sign==45 then --ascii('-')
    v = -v
    if v>0 then error("negative bignum is out of range") end
  else
    if v<0 then error("positive bignum is out of range") end
  end
  return v, pos+4
end

local function _load_string(s, i)
  local n, pos = _load_fixnum(s, i)
  if n<0 then error("negative string/symbol length is illegal") end
  return s:sub(pos, pos+n-1), pos+n
end

local function _load_symbol(s, i, syms)
  local r, pos = _load_string(s, i)
  insert(syms, r)
  return r, pos
end

local function _load_ivar(s, i, syms)
  local numivars, enc, flag
  local r, pos = _load(s, i, syms)
  numivars, pos = _load_fixnum(s, pos)
  if numivars<0 or numivars>1 then error("unsupported ivar") end
  enc, pos = _load(s, pos, syms)
  if enc ~= "E" then error("unsupported encoding other than ascii or utf8") end
  flag, pos = _load(s, pos, syms)
  if flag ~=true and flag ~= false then error("bad istring format,need true or false flag") end
  return r, pos
end

local function _load_hash(s, i, syms)
  local k, v
  local n, pos = _load_fixnum(s, i)
  local t = {}
  for i=1, n do
    k, pos = _load(s, pos, syms)
    v, pos = _load(s, pos, syms)
    t[k] = v
  end
  return t, pos
end

local function _load_array(s, i, syms)
  local v
  local n, pos = _load_fixnum(s, i)
  local t = {}
  for i=1, n do
    t[i], pos = _load(s, pos, syms)
  end
  return t, pos
end

local function _load_symbol_link(s, i, syms)
  local idx, pos = _load_fixnum(s, i)
  if idx<0 or idx>=#syms then error("bad symbol link index") end
  return syms[idx+1], pos
end

function _load(s, i, syms)
  local typ = s:byte(i)
  local pos = i+1
  if typ == 48 then return nil, pos end --ascii('0')
  if typ == 84 then return true, pos end --ascii('T')
  if typ == 70 then return false, pos end --ascii('F')
  if typ == 105 then return _load_fixnum(s, pos) end --ascii('i')
  if typ == 108 then return _load_bignum(s, pos) end --ascii('l')
  if typ == 34 then return _load_string(s, pos) end --ascii('"')
  if typ == 58 then return _load_symbol(s, pos, syms) end --ascii(':')
  if typ == 123 then return _load_hash(s, pos, syms) end --ascii('{')
  if typ == 91 then return _load_array(s, pos, syms) end --ascii('[')
  if typ == 73 then return _load_ivar(s, pos, syms) end --ascii('I')
  if typ == 59 then return _load_symbol_link(s, pos, syms) end --ascii(';')
  error("unsupported ruby datatype or malformed data")
end

function Marshal:load(s)
  local vmajor, vminor = s:byte(1, 2)
  if vmajor~=4 or vminor~=8 then error("bad ruby marshal version") end
  local syms = {}
  return (_load(s, 3, syms))
end

function dump(t)
  error("not implemented")
end

return Marshal
