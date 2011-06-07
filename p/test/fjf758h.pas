{ Cf. the note in EP, 6.2.1 }

{ FLAG extended-pascal }

program fjf758h (Output);

procedure foo; forward;

const
  a = 1;

procedure foo;  { WRONG }
begin
  WriteLn ('failed')
end;

begin
  foo
end.
