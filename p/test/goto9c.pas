{$no-iso-goto-restrictions}
{$W-}
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
     goto 10
   end;

begin
 p;
end
.
