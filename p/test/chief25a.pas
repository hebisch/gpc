program Chief25a;

{$W-}

Function O ( s : string ) : string;
begin
  O := 'O' + s
end;

Function  K : string;
begin
   K := 'K'
End;

Function OK ( s : string ) : string; forward;
Function OK ( s : string ) : string;
Begin
  OK := O ( K )
End;

begin
  writeln (OK (''))
End.
