unit u2;

interface

uses
  u1 in 'jesper2u.pas';

procedure Proc2 (x : recPtr);


implementation

procedure Proc2 (x : recPtr);
begin
  Proc1 (x);  { This call is OK -- no compiler errors! }
end;

begin

end. { u2 }
