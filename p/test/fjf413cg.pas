program fjf413cg;

type
  c = array [1 .. 42] of Integer;
  d = c;
  TFoo = ^c   	    	
          (* blah *)  { blah }
..  (* blah *)  { blah } 	
^d   (* blah *)  { blah }   	
;

var
  Foo : TFoo;

begin
  if (Low (Foo) = #3) and (High (Foo) = ^d  	
    )
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
