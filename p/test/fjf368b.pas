program fjf368b;

procedure foo (const a : array [m .. n : Integer] of Integer);
begin
  a [m] := 0  { WRONG }
end;

begin
  WriteLn ('failed')
end.
