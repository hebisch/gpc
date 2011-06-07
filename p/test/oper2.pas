Program Oper2;


Operator + ( x, y: Integer ): Integer;  { WARN - misleading warning }

begin { + }
end { + };


begin
  writeln ( 'failed' );
end.
