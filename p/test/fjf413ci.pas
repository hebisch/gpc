program fjf413ci;

type
  {$W-}
  TFoo = ^	    	
          (* blah *)  { blah }
 (* blah *)  { blah }  	
..  (* blah *)  { blah } 	
^   (* blah *)  { blah }   	
; {$W+}

var
  Foo : TFoo;

begin
  if (Low (Foo) = #73) and (High (Foo) = ^  	
    )
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
