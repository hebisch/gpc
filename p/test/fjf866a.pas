unit fjf866a;

interface

procedure foo;

implementation

procedure foo;
const a: Integer = 1;
begin
{$local W-}
  Inc (a);
{$endlocal}
end;

end.
