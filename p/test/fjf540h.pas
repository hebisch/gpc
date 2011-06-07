{$borland-pascal}

program fjf540h;

var
  a: Integer;
  b: ^Byte;

begin
  b := @a;  { WRONG }
  WriteLn ('failed')
end.
