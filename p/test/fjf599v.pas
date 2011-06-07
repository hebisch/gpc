unit fjf599v;

interface

type
  t (a: Integer) = array [1 .. a] of Char;

procedure p (s: t);

implementation

procedure p (s: t);
begin
  WriteLn (s)
end;

end.
