{$define DoTestNum 7}
program reade7 (Output);

{ FLAG -O0 }

{$define Standard}

{$i read1.inc}

{$W-,extended-pascal,no-mixed-comments,macros}

{$i read2.inc}

begin
  dialect:='EP';
  hex:=False;
  test
end.
