program sam6;

var v1 : PACKED ARRAY [0 .. 10000] OF integer;

procedure p1(var map: PACKED ARRAY [lo..hi: integer] OF integer);
begin
  writeln ( 'OK' );
end;


procedure p2;
begin
   p1(v1);
end;

begin
  p2;
end.
