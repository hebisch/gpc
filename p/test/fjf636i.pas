program fjf636h;

type
  a = object
    f: Integer
  end;

var
  v: a;

begin
  SetLength (TypeOf (v)^.Name^, 1);  { WRONG }
  WriteLn ('failed')
end.
