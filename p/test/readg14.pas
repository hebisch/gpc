{$define DoTestNum 14}
program readg14;

{ FLAG -O0 -Wno-unused }

{$i read1.inc}

{$i read2.inc}

begin
  dialect:='GPC';
  test
end.
