program fjf69;

procedure p(var a:array[b..c:integer;d..e:integer] of integer);
begin
 if ( b = 1 ) and ( c = 2 ) and ( d = 3 ) and ( e = 4 ) then
   writeln ( 'OK' )
 else
   writeln('failed: ', b,' ',c,' ',d,' ',e)
end;

var a:array[1..2,3..4] of integer;
    i, j: integer;

begin
 for i:= 1 to 2 do
   for j:= 3 to 4 do
     a [ i, j ]:= 42;
 p(a)
end.
