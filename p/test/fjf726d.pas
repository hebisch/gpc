program fjf726d;

procedure t;
begin
end;

begin
  if AlignOf (t) > 0 then WriteLn ('OK') else WriteLn ('failed ', AlignOf (t))
end.
