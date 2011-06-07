{ local static variables are initialized and finalized in the wrong place }

program fjf458a;

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

begin
  foo (1);
  foo (2);
  foo (3);
  foo (4);
end.
