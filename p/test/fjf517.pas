{
Failed on mips-sgi-irix* (SetLength):

Assembler messages:
Error: illegal operands `sw'
}

{ FLAG -O2 }

program fjf517;

uses fjf517u;

function Foo = s: TString;
begin
  s := 'failed';
  SetLength (s, 0);
  s := s + 'OK'
end;

begin
  WriteLn (Foo)
end.
