program fjf413cc;

type
  c = array [1 .. 42] of Integer;
  TFoo = ^c   	    	
          (* blah *)  { blah }
  	;

var
  Foo : TFoo;
  Bar : c;

begin
  Foo := @Bar;
  WriteLn ('OK')
end.
