{ Failed on AIX with gcc-2.x }

program fjf955;
var
  s: String (9) = 'foobarbaz';
  x: Pointer;
begin
  x := ReturnAddress (0);
  s := s + '' + '';
  if x = ReturnAddress (0) then WriteLn ('OK') else WriteLn ('failed')
end.
