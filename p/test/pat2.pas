unit Pat2;

interface

procedure Identify(Protected This_String : string);

implementation

procedure Identify(Protected This_String : string);
begin
  write ( This_String [ 2 ] );
{$if 0 }
  WriteLn('Capacity ',This_String.Capacity);
  WriteLn('Length   ',Length(This_String)); {<- this is always correct }
  WriteLn('Contains ',This_String);
{$endif }
end;

begin
end.
