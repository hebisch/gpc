program fjf198;
{OK}

uses fjf198a;

var v:a;
    s:string(20);

begin
  reset (v,ParamStr (1));
  readln (v);
  readln (v,s);
  writeln (s[2..3])
end.
