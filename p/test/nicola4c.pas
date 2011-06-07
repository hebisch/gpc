program Nicola4c;

procedure Routine;

  procedure SubRoutine;
  begin
  end;

const
  p: procedure = SubRoutine;  { WRONG -- addresses not constant }

begin
end;

begin
end.
