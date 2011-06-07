{ FLAG --classic-pascal }

PROGRAM testnn2(output);

procedure foo;
begin
end;

  CONST  { WRONG }
    c = 2;

  BEGIN
  writeln('Failure to detect misordered declarations');
  END.
