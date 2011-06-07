program fjf565j;

function foo (bar: Integer): Integer;
var qwe: Integer;

  procedure baz;
  var qwe: Integer;
  begin
    qwe := 0;
    WriteLn ('OK')
  end;

begin
  qwe := 0;
  baz;
  Return 42
end;

begin
  if foo (0) <> 42 then WriteLn ('failed')
end.
