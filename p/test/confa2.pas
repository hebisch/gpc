program conf;
var av1 : string(5) value 'xxx';
    av2 : string(4) value 'yyy';
    ok : boolean value true;
procedure p(a1, a2 : packed array[l..h:integer] of char);
begin
  if (a1 <> 'xxx') or (a2 <> 'yyy') then
    ok := false
end;
begin
  p('xxx', 'yyy');
  p(av1, av2);
  if ok then
    writeln('OK')
end
.
