program fjf1071b (Output);

type
  i3 = Integer value 3;

procedure Test4;
type
  r2 = record
         a: Integer;
       case b: Integer of
         1: (c: i3);
         otherwise (d: Integer)
       end value [a: 1; case b: 2 of [d: 4]];
var
  p2: ^r2;
begin
  New (p2, 1);  { WRONG }
end;

begin
  Test4
end.
