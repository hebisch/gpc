program fjf857;

function f: Integer;

  procedure g;

    procedure h;
    var f: Integer;
    begin
      f := 17
    end;

  begin
    f := 42;
    h
  end;

begin
  g
end;

begin
  if f = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
