program fjf645d;

type
  a = object end;
  b = object (a) procedure foo; abstract; end;  { WARN }

begin
  WriteLn ('failed')
end.
