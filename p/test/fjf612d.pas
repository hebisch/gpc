program fjf612d;

type
  s (d, e: Integer) = array [d .. e] of Integer;

var c, d: Integer value 42;

function ask1 : Integer;
  begin
    if c <> 42 then begin WriteLn('Failed 1 ', c); Halt end;
    ask1 := c;
    c := c + 1
  end;

function ask2 : Integer;
  begin
    if d <> 42 then begin WriteLn('Failed 2 ', d); Halt end;
    ask2 := d;
    d := d + 1
  end;

var
  b: ^s;

begin
  New (b, ask1, ask2 + 20);
  if (SizeOf (b^) <> 23 * SizeOf (Integer)) or (Low (b^) <> 42) or (High (b^) <> 62) then
    begin
      WriteLn ('failed 3 ', SizeOf (b^), ' ', Low (b^), ' ', High (b^));
      Halt
    end;
  WriteLn ('OK')
end.
