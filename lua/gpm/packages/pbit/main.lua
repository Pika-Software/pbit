local string_format = string.format
local table_concat = table.concat
local math_floor = math.floor
local math_Clamp = math.Clamp
local math_ceil = math.ceil
local math_log = math.log
local math_max = math.max
local tonumber = tonumber
local assert = assert
local type = type

module("pbit", package.seeall)

local function tobittable_r(x, ...)
    if (x or 0) == 0 then return ... end
    return tobittable_r(math_floor(x / 2), x % 2, ...)
end

local function tobittable(x)
    assert( type(x) == "number", "bad argument #1 to 'tobittable' (number expected, got " .. type(x) .. ")" )
    if x == 0 then return { 0 } end
    return { tobittable_r(x) }
end

local function makeop(cond)
    local function oper(x, y, ...)
        if not y then return x end
        x, y = tobittable(x), tobittable(y)
        local xl, yl = #x, #y
        local t, tl = {}, math_max(xl, yl)
        for i = 0, tl - 1 do
            local b1, b2 = x[xl - i], y[yl - i]
            if not (b1 or b2) then break end
            t[tl - i] = (cond((b1 or 0) ~= 0, (b2 or 0) ~= 0) and 1 or 0)
        end
        return oper(tonumber(table_concat(t), 2), ...)
    end
    return oper
end

band = makeop(function(a, b) return a and b end)
bor = makeop(function(a, b) return a or b end)
bxor = makeop(function(a, b) return a ~= b end)

function bnot(x, bits)
    return bxor(x, (2 ^ (bits or math_floor(math_log(x, 2)))) - 1)
end

function lshift(x, bits)
    return math_floor(x) * (2 ^ bits)
end

function rshift(x, bits)
    return math_floor(math_floor(x) / (2 ^ bits))
end

function tobin(x, bits)
    local r = table_concat(tobittable(x))
    return ("0"):rep((bits or 1) + 1 - #r) .. r
end

function frombin(x)
    return tonumber(x:match("^0*(.*)"), 2)
end

function bset(x, bitn)
    return bor(x, 2 ^ bitn)
end

function bunset(x, bitn)
    return band(x, bnot(2 ^ bitn, math_ceil(math_log(x, 2))))
end

function bisset(x, bitn, ...)
    if not bitn then return end
    return rshift(x, bitn) % 2 == 1, bisset(x, ...)
end

function Vec4ToInt(a, b, c, d)
	local int = 0
	int = int + lshift(math_Clamp(tonumber(a), 0, 255), 24)
	int = int + lshift(math_Clamp(tonumber(b), 0, 255), 16)
	int = int + lshift(math_Clamp(tonumber(c), 0, 255), 8)
	int = int + math_Clamp(tonumber(d), 0, 255)
	return int
end

function Vec4FromInt(i)
	return rshift(band(i, 0xFF000000), 24),
	rshift( band(i, 0x00FF0000), 16),
	rshift( band(i, 0x0000FF00), 8),
	band(i, 0x000000FF)
end

local toInt = "(%d+)%.(%d+)%.(%d+)%.(%d+)"
function IPAddressToInt(ip)
	return Vec4ToInt( ip:match( toInt ) )
end

local baseFormat = "%d.%d.%d.%d"
function IPAddressFromInt(i)
	return baseFormat:format( Vec4FromInt( i ) )
end

local COLOR = FindMetaTable("Color")
function COLOR:ToInt()
    return Vec4ToInt( self["r"], self["g"], self["b"], self["a"] )
end

function COLOR:FromInt(i)
    self["r"], self["g"], self["b"], self["a"] = Vec4FromInt( i )
end