program qualid1(Output);
import mod13u; mod13v;
var fail : boolean;
begin
  fail := false;
  if (v1 <> 1) or (v2 <> 2) then begin
    writeln('failed1');
    fail := true;
  end;
  if f1 or f2 then begin
    writeln('failed2');
    fail := true;
  end;
  if not fail then writeln('OK')
end
.
