program numericIO(output);
  const n = 500; d = 0.12345;
  var i: integer; x,s: real;
      f: file of real;
begin
  x := 1.0; s := 0; rewrite(f);
  for i := 1 to n do
    begin write(f,x); s := s+x; x := x+d
    end ;
  writeln(s:0:5);
  reset(f); s := 0;
  while not eof(f) do
    begin read(f,x); s := s+x
    end ;
  writeln(s:0:5)
end .
