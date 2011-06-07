{$implicit-result}

program fjf281a;

type
  t = string(42);

function f : t; forward;

function f : t;
begin
  if result.capacity <> 42 then
    begin
      writeln ('failed: ', result.capacity);
      halt
    end;
  f := 'OK'
end;

begin
  writeln (f)
end.
