program fjf639t;

type
  pt = ^t;
  t = object end;

  pu = ^u;
  u = object (t) end;

var
  v: pt;

begin
  v := New (pt);
  if v^ is u then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  v := New (pu);
  if not (v^ is u) then
    begin
      WriteLn ('failed 2');
      Halt
    end;
  WriteLn ('OK')
end.
