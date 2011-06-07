program fjf413ch;

type
  c = array [1 .. 42] of Integer;
  TFoo = ^	    	
          (* blah *)  { blah }
 (* blah *)  { blah }  	
c;

var
  Foo : TFoo;
  Bar : c;

begin
  Foo := @Bar;
  WriteLn ('OK')
end.
