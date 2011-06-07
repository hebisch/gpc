program bugtest;

var
 i,j,k:integer;
 r:real;

const
  eps = 1e-6;

begin

 for i:= 1 to 100 do begin
  r:=random;r:=0.235;
  j:=trunc(r*100);
  k:=round(r*100);
  if (j <= r * 100 - 1 - eps) or (j > r * 100 + eps) or (k <= r * 100 - 0.5 - eps) or (k > r * 100 + 0.5 + eps) then
    begin
      writeln(j:4,k:4,r*100:4:0,r:8:4);
      halt
    end
 end;
 writeln ('OK')
end.
