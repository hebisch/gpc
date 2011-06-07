program fjf368a;

procedure foo (protected var a : array [m .. n : Integer] of Integer);
begin
  a [m] := 0  { WRONG }
end;

begin
  WriteLn ('failed')
end.
