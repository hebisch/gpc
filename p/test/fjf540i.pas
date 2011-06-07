{$borland-pascal}

{$T+}

program fjf540i;

var
  a: Integer;
  b, c: ^Byte;

begin
  b := Addr (a);
  c := Addr (a);
  if b = c then WriteLn ('OK') else WriteLn ('failed')
end.
