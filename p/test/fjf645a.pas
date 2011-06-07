program fjf645a;

type
  a = object end;
  b = abstract object (a) end;  { WARN }

begin
  WriteLn ('failed')
end.
