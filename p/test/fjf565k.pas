{ FLAG -Wshadow }

program fjf565k;

function foo (bar: Integer): Integer;
var qwe: Integer;

  procedure baz;
  var qwe: Integer;  { WARN }
  begin
    qwe := 42
  end;

begin
  qwe := 42;
  Return 0
end;

begin
  WriteLn ('failed')
end.
