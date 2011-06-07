program Nicola4d;

procedure Routine;

  procedure SubRoutine;
  begin
    WriteLn ('OK')
  end;

var
  p: procedure = SubRoutine;

begin
  p
end;

begin
  Routine
end.
