program adam3c;

function at(const index:integer):integer;
begin
  case index of
    3: at := 42;
    else at := 0
  end
end;

begin
  if at(3) = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
