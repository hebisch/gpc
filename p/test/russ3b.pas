program russ3b;

const MAXLINES = 20000;

type
  lline         = String ( 4000 );      {buffer for data xfer}

procedure foo;
var
  cap : integer;

type
  ptrline  = ^String;

{  Line = String ( cap ); -- This was there originally, but it's wrong.
                             Setting cap later cannot change this declaration.
                             But it's not used, anyway. -- Frank, 20050117 }

  TbbArray      = array[1..MAXLINES] of ptrline;

var
  BigBuffer  : TbbArray;                {array of pointers to data}
  LineCount  : integer = 0;

procedure BB_AddLine( ALine: lline );
begin
  cap := Length (ALine);
  inc( LineCount );
  BigBuffer[ LineCount ] := new( ptrline, cap );
  BigBuffer[ LineCount ]^ := ALine;
end;

begin
  BB_AddLine ('OK');
  if LineCount = 1 then WriteLn (BigBuffer[1]^) else WriteLn ('failed ', LineCount)
end;

begin
  foo
end.
