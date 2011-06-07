program fjf636f;

type
  a = object
    f: Integer
  end;

var
  v: a;

begin
  TypeOf (v) := nil;  { WRONG }
  WriteLn ('failed')
end.
