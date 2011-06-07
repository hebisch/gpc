{ FLAG -Wshadow }

program fjf565i;

function foo (bar: Integer): Integer;

  procedure baz;
  var bar: Integer;  { WARN }
  begin
    bar := 42
  end;

begin
  Return 0
end;

begin
  WriteLn ('failed')
end.
