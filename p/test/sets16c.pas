program sets16c;

   type
     Str = packed set of 1..255;
     sss = set of 1..100;

   procedure Doit( const var s: Str );
   begin
   end;

begin
   Doit(sss[1..2]); { WRONG }
end.

