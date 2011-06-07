{ FLAG --classic-pascal }

PROGRAM testnn2(output);

  CONST
    a = 1;

  TYPE
    b = integer;

  CONST  { WRONG }
    c = 2;

  BEGIN
  writeln('Failure to detect misordered declarations');
  END.
