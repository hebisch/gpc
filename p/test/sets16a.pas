program sets16a;
{$setlimit=1024}

   type
     Str = set of 1..1000;

   procedure Doit( const s: Str );
   begin
   end;
   function fiuu : aa2; { WRONG }
   begin
     fiuu := [1..2];
   end;

begin
   Doit(fiuu); { but gpc-20051116 crashed here }
end.

