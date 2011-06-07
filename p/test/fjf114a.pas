program fjf114a;
type a(b:integer)=integer;

procedure p(x:integer);
begin
  if x <> 3 then
    begin
      WriteLn ('failed 1 ', x);
      Halt
    end
end;

procedure q(x:a);
begin
  if (x <> 3) or (x.b <> 42) then
    begin
      WriteLn ('failed 2 ', x, ' ', x.b);
      Halt
    end;
end;

var c:a(42);
begin
  c:=3;
  p(c);
  q(c);
  WriteLn ('OK')
end.
