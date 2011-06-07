program adam3f;

function at(protected index:integer):integer;
begin
  case index of
    3..3: at := 42;
    else at := 0
  end
end;

begin
  if at(3) = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
