program delphi6l(output);
type rt = record i : integer end;
function foo:rt;
begin
  foo().i := 0 { WRONG }
end;
begin
  Writeln ('failed');
end
.
