program fjf565h;

function foo (bar: Integer): Integer;

  procedure baz;
  var bar: Integer;
  begin
    bar := 42;
    WriteLn ('OK')
  end;

begin
  baz;
  Return 42
end;

begin
  if foo (0) <> 42 then WriteLn ('failed')
end.
