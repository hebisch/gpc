program fjf565g;

function foo (bar: Integer): Integer;

  procedure bar;  { WRONG }
  begin
  end;

begin
  Return 0
end;

begin
  WriteLn ('failed')
end.
