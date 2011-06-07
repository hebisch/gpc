{$B+}

program fjf552b;

var
  CalledX, CalledY : Boolean = False;

function X: Boolean;
begin
  CalledX := True;
  X := True
end;

function Y: Boolean;
begin
  CalledY := True;
  Y := False
end;

begin
  if X or Y then
    if not CalledX then
      WriteLn ('failed 2')
    else if not CalledY then
      WriteLn ('failed 3')
    else
      WriteLn ('OK')
  else
    WriteLn ('failed 1')
end.
