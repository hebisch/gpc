program withbug(output);

type
   dptr = ^dtype;
   dtype = record
      n: integer;
   end;

   fptr = ^ftype;
   ftype = record
      n: integer;
   end;

var
   n: integer;
   f: fptr;
   d: dptr;

procedure p;
begin
   with  f^ ,  d^  do begin end;
end;

begin
  n := 1;
  writeln('OK');
end
.
