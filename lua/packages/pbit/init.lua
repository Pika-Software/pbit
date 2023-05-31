
local string = string
local math = math

local table_concat = table.concat
local ArgAssert = ArgAssert
local tonumber = tonumber
local Color = Color

local lib = {}

local function tobittable_r( x, ... )
    if ( x or 0 ) == 0 then return ... end
    return tobittable_r( math.floor( x / 2 ), x % 2, ... )
end

local function tobittable( x )
    ArgAssert( x, 1, "number" )
    if x == 0 then return { 0 } end
    return { tobittable_r( x ) }
end

local function makeop( cond )
    local function oper( x, y, ... )
        if not y then return x end
        x, y = tobittable( x ), tobittable( y )

        local xl, yl = #x, #y
        local t, tl = {}, math.max( xl, yl )
        for i = 0, tl - 1 do
            local b1, b2 = x[ xl - i ], y[ yl - i ]
            if not ( b1 or b2 ) then break end
            t[ tl - i ] = ( cond( ( b1 or 0 ) ~= 0, ( b2 or 0 ) ~= 0 ) and 1 or 0 )
        end

        return oper( tonumber( table_concat( t ), 2 ), ... )
    end

    return oper
end

lib.band = makeop( function( a, b )
    return a and b
end )

lib.bor = makeop( function( a, b )
    return a or b
end )

lib.bxor = makeop( function( a, b )
    return a ~= b
end )

function lib.bnot( x, bits )
    return lib.bxor( x, ( 2 ^ ( bits or math.floor( math.log( x, 2 ) ) ) ) - 1 )
end

function lib.lshift( x, bits )
    return math.floor( x ) * ( 2 ^ bits )
end

function lib.rshift( x, bits )
    return math.floor( math.floor( x ) / ( 2 ^ bits ) )
end

function lib.tobin( x, bits )
    local r = table_concat( tobittable( x ) )
    return string.rep( "0", ( bits or 1 ) + 1 - #r ) .. r
end

function lib.frombin( x )
    return tonumber( string.match( x, "^0*(.*)" ), 2 )
end

function lib.bset( x, bitn )
    return lib.bor( x, 2 ^ bitn )
end

function lib.bunset( x, bitn )
    return lib.band( x, lib.bnot( 2 ^ bitn, math.ceil( math.log( x, 2 ) ) ) )
end

function lib.bisset( x, bitn, ... )
    if not bitn then return end
    return lib.rshift( x, bitn ) % 2 == 1, lib.bisset( x, ... )
end

function lib.Vec4ToInt( a, b, c, d )
    return lib.lshift( math.Clamp( tonumber( a ), 0, 255 ), 24 )
    + lib.lshift( math.Clamp( tonumber( b ), 0, 255 ), 16 )
    + lib.lshift( math.Clamp( tonumber( c ), 0, 255 ), 8 )
    + math.Clamp( tonumber( d ), 0, 255 )
end

function lib.Vec4FromInt( x )
    return lib.rshift( lib.band( x, 0xFF000000 ), 24 ),
    lib.rshift( lib.band( x, 0x00FF0000 ), 16 ),
    lib.rshift( lib.band( x, 0x0000FF00 ), 8 ),
    lib.band( x, 0x000000FF )
end

-- ip2int
function lib.IPAddressToInt( ip )
    return lib.Vec4ToInt( string.match( ip, "(%d+)%.(%d+)%.(%d+)%.(%d+)" ) )
end

function lib.IPAddressFromInt( x )
    return string.format( "%d.%d.%d.%d", lib.Vec4FromInt( x ) )
end

-- color2int
function lib.ColorToInt( color )
    return lib.Vec4ToInt( color.r, color.g, color.b, color.a )
end

function lib.ColorFromInt( x )
    return Color( lib.Vec4FromInt( x ) )
end

return lib
