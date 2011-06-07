{$W no-inherited-abstract}

program fjf645c;

type
  a = object end;
  b = abstract object (a) end;

begin
  WriteLn ('OK')
end.
