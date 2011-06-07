program sets15(Output);
var s1 : set of 0..255;
    s2 : set of 64..128;
    ok : boolean;

procedure p1;
begin
  if s1 = s2 then begin 
    writeln('failed1');
    ok := false;
  end;
end;

procedure p2;
begin
  if s1 <= s2 then begin
    writeln('failed2');
    ok := false;
  end;
end;


procedure ii;
begin
  s2 := [66];
  s1 := [66, 197];
end;

begin
  ok := true;
  ii;
  p1;
  p2;
  if ok then writeln('OK')
end
.
