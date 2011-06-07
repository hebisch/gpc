program BO4_18;

type
  PString = ^String;

function a: Pointer;
const c: String (10) = 'abcd';
begin
  a := @c
end;

begin
  if (Length (PString (a)^) >= 4) and (PString (a)^[1 .. 4] = 'abcd') then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
