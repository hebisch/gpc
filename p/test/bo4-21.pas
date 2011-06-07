program BO4_21;

uses BO4_21u;

procedure p (a: PtrInt);
begin
  if a = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  v := p;
  v (42)
end.
