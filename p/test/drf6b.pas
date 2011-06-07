{$borland-pascal}

program drf6b;

var
  a : 0 .. 2;

begin
  a := 0;
  case a of
    1 : ;
    0 .. 2 : ;  { WARN }
  end
end.
