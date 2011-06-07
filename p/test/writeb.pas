program writeb;

{ FLAG -O0 }

{$define Borland}

{$i write1.inc}

{$W-,borland-pascal,macros}

{$i write2.inc}

begin
  dialect:='BP';
  capexp:=True;
  test
end.
