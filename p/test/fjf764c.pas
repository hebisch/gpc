program fjf764c;

function a: Integer;

  function a: Integer;  { WRONG }
  begin
    a := 42
  end;

begin
  a := a
end;

begin
end.
