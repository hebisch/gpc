unit fjf458u;

interface

procedure foo (i : Integer);

implementation

procedure foo (i : Integer);
var
  t : Text; attribute (static);
  s : String (10);
begin
  case i of
    1 : Rewrite (t);
    2 : WriteLn (t, 'OK');
    3 : Reset (t);
    4 : begin
          ReadLn (t, s);
          WriteLn (s)
        end
  end
end;

end.
