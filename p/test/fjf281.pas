{$implicit-result}

program fjf281;

type
  t = string(42);

  o = object
    function f : t;
  end;

function o.f : t;
begin
  if result.capacity <> 42 then
    begin
      writeln ('failed: ', result.capacity);
      halt
    end;
  f := 'OK'
end;

var
  v : o;

begin
  writeln (v.f)
end.
