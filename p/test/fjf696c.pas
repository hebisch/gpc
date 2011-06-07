program fjf696c;

type
{$W-}
  a = object
    a: String (2);
    o: procedure (var b: a);
  end;
{$W+}

procedure p (var d: a);
begin
  WriteLn (d.a)
end;

var
  v, w: a;

begin
  v.a := 'XX';
  v.o := p;
  w.a := 'OK';
  w.o := nil;
  v.o (w)
end.
