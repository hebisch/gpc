{$B+}

program fjf552a;

var
  CalledX, CalledY : Boolean = False;

function X: Boolean;
begin
  CalledX := True;
  X := False
end;

function Y: Boolean;
begin
  CalledY := True;
  Y := False
end;

begin
  if X and Y then
    WriteLn ('failed 1')
  else if not CalledX then
    WriteLn ('failed 2')
  else if not CalledY then
    WriteLn ('failed 3')
  else
    WriteLn ('OK')
end.
