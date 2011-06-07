{ FLAG -fclassic-pascal }
program pack13(output);
procedure p;
var a : packed array [1..10] of file of integer;
    r : packed record f : file of integer end;
    ar : array [1..10] of packed record f : file of integer end;
    ra : record a : packed array [1..10] of file of integer end;
begin
  writeln('OK')
end;
begin
  p
end
.
