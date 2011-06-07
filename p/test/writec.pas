program writec;

{ FLAG -O0 }

{$define Classic}
{$define Standard}

{$i write1.inc}

{$W-,classic-pascal,macros}

{$i write2.inc}

begin
  dialect:='SP';
  clipstr:=True;
  fint:=11;
  freal:=23;
  fbool:=6;
  flint:=21;
  flreal:=29;
  test
end.
