program fjf458d;

procedure foo (i : Integer);
var s : String (10);
begin
  var t : Text; attribute (static);
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

begin
  foo (1);
  foo (2);
  foo (3);
  foo (4);
end.
