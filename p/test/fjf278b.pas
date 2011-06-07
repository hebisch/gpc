program fjf278b;
var a:boolean=false;
begin
  repeat
    if a then begin writeln('OK');halt; end;
    case a of
      false : begin a := true; continue; end;
      else
        writeln ('failed');
        halt
    end;
  until false
end.
