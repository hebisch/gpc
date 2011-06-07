{$object-pascal}
program gale7z(output);
type rt = 0..255;
     t1 = record 
          f1 : record rt : integer end;
          f2 : rt;
         end;
     t2(d : rt) = record
          f1 : record d : integer end;
         end;
     t3 = class
         f1 : rt;
         procedure f2(rt : integer);
         function f3(i : integer) = rt : integer;
         end;
procedure t3.f2;
begin
end;
function t3.f3;
begin
  rt := i
end;
begin
  writeln('OK')
end
.
