{$define DoTestNum 7}
program readc7 (Output);

{ FLAG -O0 }

{$define Classic}
{$define Standard}

{$i read1.inc}

{$W-,classic-pascal,no-mixed-comments,macros}

{$i read2.inc}

begin
  dialect:='SP';
  base:=False;
  hex:=False;
  realiso7185:=True;
  test
end.
