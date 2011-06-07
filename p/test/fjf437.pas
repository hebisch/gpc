{ This is extremely ugly, but some BP code actually does such things. }

{ FLAG --uses=system }

program fjf437;

type
  PInteger = ^Integer;

var
  i : Integer;
  a : array [1 .. 10] of Integer;

begin
  for i := 1 to 10 do a [i] := 0;
  a [7] := 42;
  if PInteger (Ptr (Seg (a), Ofs (a) + 6 * SizeOf (Integer)))^ = 42
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
