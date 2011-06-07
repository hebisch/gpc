program writee;

{ FLAG -O0 }

{$define Standard}

{$i write1.inc}

{$W-,extended-pascal,macros}

{$i write2.inc}

begin
  dialect:='EP';
  clipstr:=True;
  fint:=11;
  freal:=23;
  fbool:=6;
  flint:=21;
  flreal:=29;
  test
end.
