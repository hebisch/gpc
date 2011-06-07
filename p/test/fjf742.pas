program fjf742;

type
  TReal = Integer;
  foobar  { WRONG }

procedure SetPrecisionReal (NewPrecision: Word);
var Dummy: Word;
begin
  Dummy := NewPrecision
end;

begin
  WriteLn ('failed')
end.
