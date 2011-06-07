{ FLAG -w }

program fjf467b;

procedure foo (i : Integer);
begin
  var i : Integer;  { WRONG }
end;

begin
  WriteLn ('failed')
end.
