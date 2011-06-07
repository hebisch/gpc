program fjf763b;

type
  t (i: Integer) = array [0 .. 15] of Char;

var
  n: Integer = 16;
  v: ^t;

procedure p (const a, b: String);
begin
  if Length (b) <> 16 then
    begin
      WriteLn ('failed ', a, ' ', Length (b));
      Halt
    end
end;

begin
  New (v, n);
  p ('1', v^[0 .. n - 1]);
  p ('2', v^[0 .. n - 1]);
  WriteLn ('OK')
end.
