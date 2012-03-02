--[[
Copyright (C) 2012 Thomas Farr a.k.a tomass1996 [farr.thomas@gmail.com]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

-The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-Visible credit is given to the original author.
-The software is distributed in a non-profit way.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local floor,modf, insert = math.floor,math.modf, table.insert
local char,format,rep = string.char,string.format,string.rep
local function lsh(value,shift)
	return (value*(2^shift)) % 256
end
local function rsh(value,shift)
	return math.floor(value/2^shift) % 256
end
local function bit(x,b)
	return (x % 2^b - x % 2^(b-1) > 0)
end
local function lor(x,y)
	result = 0
	for p=1,8 do result = result + (((bit(x,p) or bit(y,p)) == true) and 2^(p-1) or 0) end
	return result
end
local function basen(n,b)
	if n < 0 then
		sign = "-"
		n = -n
	end
       t = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_abcdefghijklmnopqrstuvwxyz{|}~"
   if n < b then
	ret = ""
	ret = ret..string.sub(t, (n%b)+1,(n%b)+1)
	return ret
   else
	tob = tostring(basen(math.floor(n/b), b))
	ret = tob..t:sub((n%b)+1,(n%b)+1)
	return ret
   end
end
local base64chars = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='I',[9]='J',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='S',[19]='T',[20]='U',[21]='V',[22]='W',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='g',[33]='h',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='q',[43]='r',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}
local base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}
local base32="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
local function bytes_to_w32 (a,b,c,d) return a*0x1000000+b*0x10000+c*0x100+d end
local function w32_to_bytes (i)
	return floor(i/0x1000000)%0x100,floor(i/0x10000)%0x100,floor(i/0x100)%0x100,i%0x100
end
local function w32_rot (bits,a)
	local b2 = 2^(32-bits)
	local a,b = modf(a/b2)
	return a+b*b2*(2^(bits))
end
local function cache2arg (fn)
	if not cfg_caching then return fn end
	local lut = {}
	for i=0,0xffff do
		local a,b = floor(i/0x100),i%0x100
		lut[i] = fn(a,b)
	end
	return function (a,b)
		return lut[a*0x100+b]
	end
end
local function byte_to_bits (b)
	local b = function (n)
		local b = floor(b/n)
		return b%2==1
	end
	return b(1),b(2),b(4),b(8),b(16),b(32),b(64),b(128)
end
local function bits_to_byte (a,b,c,d,e,f,g,h)
	local function n(b,x) return b and x or 0 end
	return n(a,1)+n(b,2)+n(c,4)+n(d,8)+n(e,16)+n(f,32)+n(g,64)+n(h,128)
end
local function bits_to_string (a,b,c,d,e,f,g,h)
	local function x(b) return b and "1" or "0" end
	return ("%s%s%s%s %s%s%s%s"):format(x(a),x(b),x(c),x(d),x(e),x(f),x(g),x(h))
end
local function byte_to_bit_string (b)
	return bits_to_string(byte_to_bits(b))
end
local function w32_to_bit_string(a)
	if type(a) == "string" then return a end
	local aa,ab,ac,ad = w32_to_bytes(a)
	local s = byte_to_bit_string
	return ("%s %s %s %s"):format(s(aa):reverse(),s(ab):reverse(),s(ac):reverse(),s(ad):reverse()):reverse()
end
local band = cache2arg (function(a,b)
	local A,B,C,D,E,F,G,H = byte_to_bits(b)
	local a,b,c,d,e,f,g,h = byte_to_bits(a)
	return bits_to_byte(
		A and a, B and b, C and c, D and d,
		E and e, F and f, G and g, H and h)
end)
local bor = cache2arg(function(a,b)
	local A,B,C,D,E,F,G,H = byte_to_bits(b)
	local a,b,c,d,e,f,g,h = byte_to_bits(a)
	return bits_to_byte(
		A or a, B or b, C or c, D or d,
		E or e, F or f, G or g, H or h)
end)
local bxor = cache2arg(function(a,b)
	local A,B,C,D,E,F,G,H = byte_to_bits(b)
	local a,b,c,d,e,f,g,h = byte_to_bits(a)
	return bits_to_byte(
		A ~= a, B ~= b, C ~= c, D ~= d,
		E ~= e, F ~= f, G ~= g, H ~= h)
end)
local function bnot (x)
	return 255-(x % 256)
end
local function w32_comb(fn)
	return function (a,b)
		local aa,ab,ac,ad = w32_to_bytes(a)
		local ba,bb,bc,bd = w32_to_bytes(b)
		return bytes_to_w32(fn(aa,ba),fn(ab,bb),fn(ac,bc),fn(ad,bd))
	end
end
local w32_and = w32_comb(band)
local w32_xor = w32_comb(bxor)
local w32_or = w32_comb(bor)
local function w32_xor_n (a,...)
	local aa,ab,ac,ad = w32_to_bytes(a)
	for i=1,select('#',...) do
		local ba,bb,bc,bd = w32_to_bytes(select(i,...))
		aa,ab,ac,ad = bxor(aa,ba),bxor(ab,bb),bxor(ac,bc),bxor(ad,bd)
	end
	return bytes_to_w32(aa,ab,ac,ad)
end
local function w32_or3 (a,b,c)
	local aa,ab,ac,ad = w32_to_bytes(a)
	local ba,bb,bc,bd = w32_to_bytes(b)
	local ca,cb,cc,cd = w32_to_bytes(c)
	return bytes_to_w32(
		bor(aa,bor(ba,ca)), bor(ab,bor(bb,cb)), bor(ac,bor(bc,cc)), bor(ad,bor(bd,cd))
	)
end
local function w32_not (a)
	return 4294967295-(a % 4294967296)
end
local function w32_add (a,b) return (a+b) % 4294967296 end
local function w32_add_n (a,...)
	for i=1,select('#',...) do
		a = (a+select(i,...)) % 4294967296
	end
	return a
end
local function w32_to_hexstring (w) return format("%08x",w) end

--String Utils :

function toCharTable(string)  --Returns table of @string's chars
	local string = tostring(string)
	local chars = {}
	for n=1,#string do
		chars[n] = string:sub(n,n)
	end
	return chars
end

function toByteTable(string)  --Returns table of @string's bytes
	local string = tostring(string)
	local bytes = {}
	for n=1,#string do
		bytes[n] = string:byte(n)
	end
	return bytes
end

function fromCharTable(chars)  --Returns string made of chracters in @chars
	return table.concat(chars)
end

function fromByteTable(bytes)  --Returns string made of bytes in @bytes
	local string = ""
	for n=1,#bytes do
		string = string..string.char(bytes[n])
	end
	return string
end

function startsWith(string,Start) --Check if @string starts with @Start
   return string.sub(string,1,string.len(Start))==Start
end

function endsWith(string,End)  --Check if @string ends with @End
   return End=='' or string.sub(string,-string.len(End))==End
end

function trim(string)  --Trim @string of initial/trailing whitespace
  return (string:gsub("^%s*(.-)%s*$", "%1"))
end

function firstLetterUpper(string)  --Capitilizes first letter of @string
	return string:gsub("%a", string.upper, 1)
end

function titleCase(string)  --Changes @string to title case
	local function tchelper(first, rest)
		return first:upper()..rest:lower()
	end
	
	return string:gsub("(%a)([%w_']*)", tchelper)
end

function isRepetition(string, pat)  --Checks if @string is a repetition of @pat
	return "" == string:gsub(pat, "")
end

function isRepetitionWS(string, pat)  --Checks if @string is a repetition of @pat seperated by whitespaces
	return not string:gsub(pat, ""):find"%S"
end

function urlDecode(string)  --Url decodes @string
	string = string.gsub (string, "+", " ")
	sString = string.gsub (string, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
	string = string.gsub (string, "\r\n", "\n")
	return string
end

function urlEncode(string)  --Url encodes @string
	if (string) then
		string = string.gsub (string, "\n", "\r\n")
		string = string.gsub (string, "([^%w ])", function (c) return string.format ("%%%02X", string.byte(c)) end)
		string = string.gsub (string, " ", "+")
	end
	return string
end

function isEmailAddress(string)  --Checks if @string is a valid email address
	if (String:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
		return true
	else
		return false
	end
end

function chunk(string, size)  --Splits @string into chunks of length @size
	if not size then return nil end
	num2App = size - (#string%size)
	string = string..(rep(char(0), num2App) or "")
	assert(#string%size==0)
	chunks = {}
	local numChunks = #string / size
	local chunk = 0
	while chunk < numChunks do
		start,chunk = chunk * size + 1,chunk+1
		if start+size-1 > #string-num2App then
			chunks[chunk] = string:sub(start, #string-num2App)
		else
			chunks[chunk] = string:sub(start, start+size-1)
		end
	end
	return chunks
end

function find(string, match, startIndex)  --Finds @match in @string optionally after @startIndex
	if not match then return nil end
	_ = startIndex or 1
	local _s = nil
	local _e = nil
	_len = match:len()
	while true do
		_t = string:sub( _ , _len + _ - 1)
		if _t == match then
			_s = _
			_e = _ + _len - 1
			break
		end
		_ = _ + 1
		if _ > string:len() then break end
	end
	if _s == nil then return nil else return _s, _e end
end

function seperate(string, divider)  --Seperates @string on @divider
	if not divider then return nil end
	local start = {}
	local endS = {}
	local n=1
	repeat
		if n==1 then
			start[n], endS[n] = find(string, divider)
		else
			start[n], endS[n] = find(string, divider, endS[n-1]+1)
		end
		n=n+1
	until start[n-1]==nil
	local subs = {}
	for n=1, #start+1 do
		if n==1 then
			subs[n] = string:sub(1, start[n]-1)
		elseif n==#start+1 then
			subs[n] = string:sub(endS[n-1]+1)
		else
			subs[n] = string:sub(endS[n-1]+1, start[n]-1)
		end
	end
	return subs
end

function jumble(string)  --Jumbles @string
	if not string then return nil end
	local chars = {}
	for i = 1, #string do
		chars[i] = string:sub(i, i)
	end
	usedNums = ":"
	res = ""
	rand = 0
	for i=1, #chars do
		while true do
			rand = math.random(#chars)
			if find(usedNums, ":"..rand..":") == nil then break end
		end
		res = res..chars[rand]
		usedNums = usedNums..rand..":"
	end
	return res
end

function toBase(string, base)  --Encodes @string in @base
	if not base then return nil end
	local res = ""
	for i = 1, string:len() do
		if i == 1 then
			res = basen(string:byte(i), base)
		else
			res = res..":"..basen(string:byte(i), base)
		end
	end
	return res
end

function fromBase(string, base)  --Decodes @string from @base
	if not base then return nil end
	local bytes = seperate(string, ":")
	local res = ""
	for i = 1, #bytes do
		res = res..(string.char(basen(tonumber(bytes[i], base), 10)))
	end
	return res
end

function toBinary(string)  --Encodes @string in binary
	if not string then return nil end
	return toBase(string, 2)
end

function fromBinary(string)  --Decodes @string from binary
	if not string then return nil end
	return fromBase(string, 2)
end

function toOctal(string)  --Encodes @string in octal
	if not string then return nil end
	return toBase(string, 8)
end

function fromOctal(string)  --Decodes @string from octal
	if not string then return nil end
	return fromBase(string, 8)
end

function toHex(string)  --Encodes @string in hex
	if not string then return nil end
	return toBase(string, 16)
end

function fromHex(string)  --Decodes @string from hex
	if not string then return nil end
	return fromBase(string, 16)
end

function toBase36(string)  --Encodes @string in Base36
	if not string then return nil end
	return toBase(string, 36)
end

function fromBase36(string)  --Decodes @string from Base36
	if not string then return nil end
	return fromBase(string, 36)
end

function toBase32(string)  --Encodes @string in Base32
	if not string then return nil end
	local byte=0
	local bits=0
	local rez=""
	local i=0
	for i = 1, string:len() do
		byte=byte*256+string:byte(i)
		bits=bits+8
		repeat 
			bits=bits-5
			local mul=(2^(bits))
			local b32n=math.floor(byte/mul)
			byte=byte-(b32n*mul)
			b32n=b32n+1
			rez=rez..string.sub(base32,b32n,b32n)
		until bits<5
	end
	if bits>0 then
		local b32n= math.fmod(byte*(2^(5-bits)),32)
		b32n=b32n+1
		rez=rez..string.sub(base32,b32n,b32n)
	end
	return rez
end

function fromBase32(string)  --Decodes @string from Base32
	if not string then return nil end
	local b32n=0
	local bits=0
	local rez=""
	local i=0
	string.gsub(string:upper(), "["..base32.."]", function (char)
		num = string.find(base32, char, 1, true)
		b32n=b32n*32+(num - 1)
		bits=bits+5
		while  bits>=8 do
			bits=bits-8
			local mul=(2^(bits))
			local byte = math.floor(b32n/mul)
			b32n=b32n-(byte*mul)
			rez=rez..string.char(byte)
		end
	end)
	return rez
end


function toBase64(string)  --Encodes @string in Base64
	if not string then return nil end
	local bytes = {}
	local result = ""
	for spos=0,string:len()-1,3 do
		for byte=1,3 do bytes[byte] = string:byte(spos+byte) or 0 end
		result = string.format('%s%s%s%s%s',result,base64chars[rsh(bytes[1],2)],base64chars[lor(lsh((bytes[1] % 4),4), rsh(bytes[2],4))] or "=",((string:len()-spos) > 1) and base64chars[lor(lsh(bytes[2] % 16,2), rsh(bytes[3],6))] or "=",((string:len()-spos) > 2) and base64chars[(bytes[3] % 64)] or "=")
	end
	return result
end

function fromBase64(string)  --Decodes @string from Base64
	if not string then return nil end
	local chars = {}
	local result=""
	for dpos=0,string:len()-1,4 do
		for char=1,4 do chars[char] = base64bytes[(string:sub((dpos+char),(dpos+char)) or "=")] end
		result = string.format('%s%s%s%s',result,string.char(lor(lsh(chars[1],2), rsh(chars[2],4))),(chars[3] ~= nil) and string.char(lor(lsh(chars[2],4), rsh(chars[3],2))) or "",(chars[4] ~= nil) and string.char(lor(lsh(chars[3],6) % 192, (chars[4]))) or "")
	end
	return result
end

function rot13(string)  --Rot13s @string
	if not string then return nil end
	rot = ""
	len = string:len()
	for i = 1, len do
		k = string:byte(i)
		if (k >= 65 and k <= 77) or (k >= 97 and k <=109) then
			rot = rot..string.char(k+13)
		elseif (k >= 78 and k <= 90) or (k >= 110 and k <= 122) then
			rot = rot..string.char(k-13)
		else
			rot = rot..string.char(k)
		end
	end
	return rot
end

function rot47(string)  --Rot47s @string
	if not string then return nil end
	rot = ""
	for i = 1, string:len() do
		p = string:byte(i)
		if p >= string.byte('!') and p <= string.byte('O') then
			p = ((p + 47) % 127)
		elseif p >= string.byte('P') and p <= string.byte('~') then
			p = ((p - 47) % 127)
		end
		rot = rot..string.char(p)
	end
	return rot
end


function sha1(string)  --Sha1s @string
	if not string then return nil end
	local H0,H1,H2,H3,H4 = 0x67452301,0xEFCDAB89,0x98BADCFE,0x10325476,0xC3D2E1F0
	local msg_len_in_bits = #string * 8
	local first_append = char(0x80) 
	local non_zero_message_bytes = #string +1 +8
	local current_mod = non_zero_message_bytes % 64
	local second_append = current_mod>0 and rep(char(0), 64 - current_mod) or ""
	local B1, R1 = modf(msg_len_in_bits  / 0x01000000)
	local B2, R2 = modf( 0x01000000 * R1 / 0x00010000)
	local B3, R3 = modf( 0x00010000 * R2 / 0x00000100)
	local B4	  =	0x00000100 * R3
	local L64 = char( 0) .. char( 0) .. char( 0) .. char( 0)
				.. char(B1) .. char(B2) .. char(B3) .. char(B4)
	string = string
	string = string .. first_append .. second_append .. L64
	assert(#string % 64 == 0)
	local chunks = #string / 64
	local W = { }
	local start, A, B, C, D, E, f, K, TEMP
	local chunk = 0
	while chunk < chunks do
		start,chunk = chunk * 64 + 1,chunk + 1
		for t = 0, 15 do
			W[t] = bytes_to_w32(string:byte(start, start + 3))
			start = start + 4
		end
		for t = 16, 79 do
			W[t] = w32_rot(1, w32_xor_n(W[t-3], W[t-8], W[t-14], W[t-16]))
		end
		A,B,C,D,E = H0,H1,H2,H3,H4
		for t = 0, 79 do
			if t <= 19 then
				f = w32_or(w32_and(B, C), w32_and(w32_not(B), D))
				K = 0x5A827999
			elseif t <= 39 then
				f = w32_xor_n(B, C, D)
				K = 0x6ED9EBA1
			elseif t <= 59 then
				f = w32_or3(w32_and(B, C), w32_and(B, D), w32_and(C, D))
				K = 0x8F1BBCDC
			else
				f = w32_xor_n(B, C, D)
				K = 0xCA62C1D6
			end
			A,B,C,D,E = w32_add_n(w32_rot(5, A), f, E, W[t], K),
				A, w32_rot(30, B), C, D
		end
		H0,H1,H2,H3,H4 = w32_add(H0, A),w32_add(H1, B),w32_add(H2, C),w32_add(H3, D),w32_add(H4, E)
	end
	local f = w32_to_hexstring
	return f(H0) .. f(H1) .. f(H2) .. f(H3) .. f(H4)
end


function encrypt(string, key)  --Encrypts @string with @key
	if not key then return nil end
	local alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_abcdefghijklmnopqrstuvwxyz{|}~"
	local _rand = math.random(#alphabet-10)
	local iv = string.sub(jumble(alphabet), _rand, _rand  + 9)
	iv = jumble(iv)
	string = iv..string
	local key = sha1(key)
	local strLen = string:len()
	local keyLen = key:len()
	local j=1
	local result = ""
	for i=1, strLen do
		local ordStr = string.byte(string:sub(i,i))
		if j == keyLen then j=1 end
		local ordKey = string.byte(key:sub(j,j))
		result = result..string.reverse(basen(ordStr+ordKey, 36))
		j = j+1
	end
	return result
end

function decrypt(string, key)  --Decrypts @string with @key
	if not key then return nil end
	local key = sha1(key)
	local strLen = string:len()
	local keyLen = key:len()
	local j=1
	local result = ""
	for i=1, strLen, 2 do
		local ordStr = basen(tonumber(string.reverse(string:sub(i, i+1)),36),10)
		if j==keyLen then j=1 end
		local ordKey = string.byte(key:sub(j,j))
		result = result..string.char(ordStr-ordKey)
		j = j+1
	end
	return result:sub(11)
end

function setRandSeed(seed)  --Sets random seed to @seed
	math.randomseed(seed)
end

setRandSeed(os.time())
