Program VarRec1;

Var
  OK: record
  case 1 .. 2 of
    1: (x: Integer);
    2: (O, K: Char);
  end;

begin
  OK.x:= $4F4B4B4F;
  WriteLn (OK.O, OK.K)
end.
