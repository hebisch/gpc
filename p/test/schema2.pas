{

Program which demonstrates string schemas.

}

program Test(output);

type
  pstring =  ^string;     { this isn't Turbo Pascal!!! }

var
  mystr : pstring;

{ Fixed: Could not `New' String Schemata with tag fields. }

begin
  { Fixed: The first `New' did destroy the type information about `mystr'. }
  New(mystr, 50);
  New(mystr, 100);
  if mystr^.capacity = 100 then
    mystr^ := 'OK'
  else
    WriteStr ( mystr^, 'failed: ', mystr^.capacity );
  writeln(mystr^);
  Dispose(mystr);
end.
