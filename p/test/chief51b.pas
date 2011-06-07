program Chief51b;

type
  b = abstract object
    procedure p; virtual;
  end;

procedure b.p;
begin
end;

begin
  WriteLn ('OK')
end.
