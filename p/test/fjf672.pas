{ FLAG -O3 }

program fjf672;

var
  foo: Integer; attribute (volatile); external;

begin
  { Since the `then' and `else' are empty, GPC can remove the whole `if'.
    However, `foo' is `volatile', so it must still be accessed which
    must lead to a link error. }
  if foo = 0 then begin end else begin end;  { WRONG }
  WriteLn ('failed')
end.
