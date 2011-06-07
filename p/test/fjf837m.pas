module fjf837m;

export fjf837m = all;

end;

var
  i: Integer;

procedure p;
begin
  Inc (i)
end;

to begin do
  for i := 1 to 2 do;  { WARN, because i is modified in p }

end.
