unit fjf79u;

interface

type t=array[0..0] of Integer;

procedure p(a:Integer;var b:t);

implementation

procedure p(a:Integer;var b:t);
begin
 b[0]:=0;
 writeln ( 'OK' );
end;
end.
