program fjf636b;

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

{$X+}

begin
  SetType (v, p);  { WRONG }
  WriteLn ('failed')
end.
