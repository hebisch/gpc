program fjf149b;

type Card1 = Cardinal attribute (Size = 1);

type a = packed array [1 .. 3, 1 .. 2, 1 .. 21] of Card1;

begin
  if (BitSizeOf (a) >= 126) and (BitSizeOf (a) <= 6 * BitSizeOf (LongestInt)) then
    WriteLn ('OK')
  else
    WriteLn ('Failed: ', BitSizeOf (a))
end.
