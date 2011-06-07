{ (optionally) warn about assigning the address of a local procedure
  (or variable?) to a global pointer variable (or returning it from a
  function?) ??? }

program fjf139;

var a: ^procedure;

procedure q (r: Integer);

  procedure p;
  begin
    WriteLn (r)
  end;

begin
  a := @p; { WARN }
  a^
end;

begin
  q (42);
  a^
end.
