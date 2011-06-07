{ assert_fail: gpc-typeck.c:2316 }

program fjf694;

procedure p (const a: array [m .. n: Integer] of Integer; var i: Integer);
begin
end;

begin
  p (foo, Null);  { WRONG }
  WriteLn ('failed')
end.
