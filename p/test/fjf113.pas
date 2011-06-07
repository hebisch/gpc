program fjf113;

function Int2Real (n: Integer): Real;
begin
  Int2Real := n
end;

function Int2LongReal (n: Integer): LongReal;
begin
  Int2LongReal := n
end;

begin
  if Abs (Int2Real (42) - Int2LongReal (42)) < 1E-15 then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
