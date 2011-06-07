{ Objects as function results }

{$W no-object-assignment}

program fjf696f;

type
{$local W-}
  a = object
    a: String (2);
    o: function: a;
  end;
{$endlocal}

var
  v, w: a;

function f: a;
begin
  f := w
end;

begin
  v.a := 'XX';
  v.o := f;
  w.a := 'OK';
  w.o := nil;
  WriteLn (v.o.a)
end.
