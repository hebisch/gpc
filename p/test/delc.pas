program delc;
type c1 = class
   procedure foo; bar; { WRONG }
   end;
   c2 = class (c1)
   procedure p;
   end; { but should not crash here }
begin
end
.
