{$no-iso-goto-restrictions}
program goto9c;

   procedure p;
   label
     10;
   begin
     if False then
       begin
         10:
            writeln('OK'); 
            Exit
       end;
     goto 10 { WARN }
   end;

begin
 p;
end
.
