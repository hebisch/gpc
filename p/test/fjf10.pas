Program fjf10;

uses
  fjf10a;

Function OK ( foo: Integer ): String255;

begin { OK }
  write ( 'O' );
  OK:= 'K';
end { OK };

begin
  WriteString ( OK ( 7 ) );
end.
