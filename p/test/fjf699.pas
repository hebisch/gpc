program fjf699;

type
  t = object
    a: Char;
  public
    b: Char;
  end;

var
  v: t;

begin
  v.a := 'K';
  v.b := 'O';
  with v do WriteLn (b, a)
end.
