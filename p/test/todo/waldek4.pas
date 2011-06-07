{ BUG with arrays of 2^32 bits on 32 bit machines.
  The problem does not seem very important, and might even vanish by
  itself in some years when we all use 64 bit machines. ;-) }

{ COMPILE-CMD: waldek4.cmp }

program bigpack;
{$if (__GNUC__ >= 3) or (__GNUC_MINOR__ >= 95)}
var bpp: packed array [-MaxInt..Maxint] of boolean;

begin
        bpp[-MaxInt]:= true;
        bpp[MaxInt]:= true;
        if  bpp[-MaxInt] and bpp[MaxInt] then
           begin
                bpp[-MaxInt] := false;
                bpp[MaxInt]:= false;
                if not bpp[-MaxInt] and not bpp[MaxInt] then
                        writeln("OK")
                else
                        writeln("failed1");
           end
        else
           writeln("failed0");
end.
{$else}
begin
  WriteLn ('SKIPPED: array size of 512 MB not supported by backend (GCC ',
           __GNUC__, '.', __GNUC_MINOR__, ')')
end.
{$endif}
