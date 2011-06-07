program delphi6k(output);
function foo:integer;
begin
  foo() := 0 { WRONG }
end;
begin
  Writeln ('failed');
end
.
