program sets16d;

   type
     Str = packed set of 1..255;
     sss = set of 1..100;

   procedure Doit( const s: Str );
   begin
   end;

begin
   Doit(sss[1..2]); { WRONG }
end.

