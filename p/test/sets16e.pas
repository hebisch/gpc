program sets16c;

   type
     Str = set of 1..255;
     sss = packed set of 1..255;
   var sv : sss;

   procedure Doit( const s: Str );
   begin
   end;

begin
   Doit(sv); { WRONG }
end.

