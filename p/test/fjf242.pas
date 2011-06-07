program fjf242;

procedure bar (baz : String);
begin
  writeln (baz)
end;

function foo (baz : CString) : CString;
begin
  foo := {$x+} baz + 1; {$x-}
end;

begin
  bar (foo ('XOK')) { WRONG } { Currently, however. In the future, this might be OK. However, passing the result of foo without conversion (which GPC did when the bug was reported), is wrong, anyway. }
end.
