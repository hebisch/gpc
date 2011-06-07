program peter112;

type
   p1 = ^MedInt;
   p2 = ^MedInt;

   procedure doit( p: p1 );
   begin
   end;

var
   p: p2;
begin
   doit( p ); { WRONG }
end.

