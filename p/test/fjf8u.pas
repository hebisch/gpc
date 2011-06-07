unit fjf8u;

interface

type t=array[0..1] of integer;

procedure p(var v:t);
procedure q(const v:t);

implementation

procedure p(var v:t);
begin
  writeln ( 'OK' );
end;

procedure q(const v:t);
begin
  writeln ( 'OK' );
end;

end.
