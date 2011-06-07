program p(output);
label 1;
var i:integer;
begin
  goto 1;                 {WRONG - violating 6.8.1 of ISO 7185}
  for i:=1 to 2 do begin
    1:writeln(i);
  end
end.
