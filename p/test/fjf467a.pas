{ FLAG -w }

program fjf467a;

procedure foo;
var i : Integer;
begin
  var i : Integer;  { WRONG }
end;

begin
  WriteLn ('failed')
end.
