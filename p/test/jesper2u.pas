unit u1;

interface

type
  rec = record
    a, b : Integer;
  end;

  recPtr = ^rec;

procedure Proc1 (x : recPtr);


implementation

procedure Proc1 (x : recPtr);
begin
  { Do nothing }
  writeln ( 'OK' );
end;

begin

end. { u1 }
