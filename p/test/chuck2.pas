PROGRAM testnn3(output);

  CONST
    mini  = 32765;
    maxi  = 32767;

  TYPE
    ix    = mini..maxi;

  VAR
    i, j   : ix;

  BEGIN
  FOR i := mini TO 32770 DO j := i;  { WRONG }
  writeln('Failed to detect out of range index');
  END.
