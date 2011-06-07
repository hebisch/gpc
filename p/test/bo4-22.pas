program BO4_22;

function f (i: Integer): Char;
begin
  f := Char (i)
end;

type
  IntPtr = ^Integer;

var
  q: IntPtr;

begin
  New (q);
  q^ := -1;
  if q^ = -1 then WriteLn ('OK') else WriteLn ('failed ', q^)
end.
