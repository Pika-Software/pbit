# pBit
Normal bitwise library without overflowing.

## Functions
- lib.IPAddressFromInt( `number` x )
- lib.IPAddressToInt( `string` ip )
- lib.ColorToInt( `Color` color )
- lib.ColorFromInt( `number` x )
- lib.Vec4FromInt( `number` x )
- lib.Vec4ToInt( `number` a, `number` b, `number` c, `number` d )
- lib.bisset( `number` x, `number` bitn, `vararg` ... )
- lib.bunset( `number` x, `number` bitn )
- lib.band( `number` a, `number` b )
- lib.bnot( `number` x, `number` bits )
- lib.bor( `number` a, `number` b )
- lib.bset( `number` x, `number` bitn )
- lib.bxor( `number` a, `number` b )
- lib.lshift( `number` x, `number` bits )
- lib.rshift( `number` x, `number` bits )
- lib.tobin( `number` x, `number` bits )
- lib.frombin( `number` x )

### Example (ip4 to int)
```lua
local pbit = install( "packages/pbit.lua" )

local st = SysTime()
local bits = pbit.IPAddressToInt( "192.168.0.1" )
print( "bits", bits, string.format( "%f", SysTime() - st ) )

st = SysTime()
local ip = pbit.IPAddressFromInt( bits )
print( "ip", ip, string.format( "%f", SysTime() - st ) )
```