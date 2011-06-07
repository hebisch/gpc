{
In this error message, just about everything is wrong: The line
number, the function (or rather, the whole unit doesn't even mention
`Y'), and the fact that there's an error at all...

fjf474b.pas: In function `Init':
fjf474b.pas:5: prior parameter's size depends on `Y'
}

program fjf474;

uses fjf474b;

begin
  WriteLn ('OK')
end.
