program delphi6m(output);
type at = array [0..0] of integer;
function foo:at;
begin
  foo()[0] := 0 { WRONG }
end;
begin
  Writeln ('failed');
end
.
