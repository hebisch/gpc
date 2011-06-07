program fjf637b;

type
  a = abstract object
  end;

var
  v: a;  { WRONG }

begin
  WriteLn ('failed')
end.
