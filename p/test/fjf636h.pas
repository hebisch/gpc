program fjf636h;

type
  a = object
    f: Integer
  end;

var
  v: a;

begin
  TypeOf (v)^.Name^[1] := 'x';  { WRONG }
  WriteLn ('failed')
end.
