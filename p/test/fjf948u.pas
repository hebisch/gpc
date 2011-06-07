unit fjf948u;

interface

procedure p (a: Integer); external name 'p';

procedure p (b: Integer);  { WRONG }

implementation

procedure p;
begin
end;

end.
