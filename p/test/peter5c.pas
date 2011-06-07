{$mac-pascal}
program peter5c(output);

   type
     ObjectA = object
       procedure Doit;
     end;
     ObjectB = object
       obj: ObjectA;
       function GetA: ObjectA;
     end;

   procedure ObjectA.Doit;
   begin
     WriteLn( 'OK' );
   end;

   function ObjectB.GetA: ObjectA;
   begin
     return obj;
   end;

var
   a: ObjectA;
   b: ObjectB;
begin
   New(a);
   New(b);
   b.obj := a;
   b.GetA.Doit;
end.

