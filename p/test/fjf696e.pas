{ Objects as value parameters }

{$W no-object-assignment}

program fjf696e;

type
{$local W-}
  a = object
    a: String (2);
    o: procedure (b: a);
  end;
{$endlocal}

procedure p (d: a);
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
