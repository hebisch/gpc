program fjf636a;

type
  a = object
    f: Integer
  end;

  b = object (a)
    g: Integer
  end;

var
  v: a;
  p: ^Integer;

begin
  p := TypeOf (v);  { WRONG }
  WriteLn ('failed')
end.
