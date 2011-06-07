program fjf636g;

type
  a = object
    f: Integer
  end;

var
  v: a;

begin
  TypeOf (v)^.Size := 0;  { WRONG }
  WriteLn ('failed')
end.
