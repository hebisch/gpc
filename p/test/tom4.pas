Program Tom4;


uses
  generic_sort in 'tom4m.pas';


Var
  A: array [ 1..4 ] of Integer value ( 42, 7, 3, 137 );


Function greater ( e1, e2: max_sort_index ): Boolean;

begin { greater }
  greater:= A [ e1 ] > A [ e2 ];
end { greater };


Procedure swap ( e1, e2: max_sort_index );

Var
  Temp: Integer;

begin { swap }
  Temp:= A [ e1 ];
  A [ e1 ]:= A [ e2 ];
  A [ e2 ]:= Temp;
end { swap };


begin
  do_the_sort ( 4, greater, swap );
  if ( A [ 1 ] = 3 )
     and ( A [ 2 ] = 7 )
     and ( A [ 3 ] = 42 )
     and ( A [ 4 ] = 137 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
