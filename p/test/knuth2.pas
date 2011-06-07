program bug(input,output);
var x : integer;
begin x:=6;
   case x mod 2 of
     0 : begin case x mod 4 of
           2 : writeln('OK');
           0 : writeln('failed');
         end; { case }
         end;
     otherwise writeln('failed');
   end; { case }
end.
