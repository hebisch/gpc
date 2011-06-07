program fjf942;

var
  a: array [1 .. 200] of Integer;
  b: String (100) absolute a;

begin
  FillChar (a, SizeOf (a), 0);
  Initialize (b);
  b := 'OK';
  WriteLn (b)
end.
