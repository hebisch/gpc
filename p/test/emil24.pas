program emil24;

var
  v : 0 .. maxint;
  d : integer;

begin
  v := 42;
  d := 10;
  v := (v mod d) * 32768;
  if v = 65536 then WriteLn ('OK') else WriteLn ('failed')
end.
