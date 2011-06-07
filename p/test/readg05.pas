{$define DoTestNum 5}
program readg5;

{ FLAG -O0 -Wno-unused }

{$i read1.inc}

{$i read2.inc}

begin
  dialect:='GPC';
  test
end.
