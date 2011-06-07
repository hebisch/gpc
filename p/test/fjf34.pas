program fjf34;
var
 a:array[10..21] of char='hello world';
 s:string(100);
begin
 writestr(s,a);
 if length(s) = 12 then
   writeln ( 'OK' )
 else
   writeln ( 'failed: ', length ( s ) );
end.
