program p(output);
var i:integer;
begin
  for i:=1 to 2 do begin
    writeln(i);
    i:=i+1                {WRONG - violating 6.8.3.9 of ISO 7185}
  end
end.
