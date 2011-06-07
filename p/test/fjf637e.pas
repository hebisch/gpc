program fjf637e;

type
  a = abstract object
  end;

  b = object (a)
  end;

var
  v: b;

begin
  WriteLn ('OK')
end.
