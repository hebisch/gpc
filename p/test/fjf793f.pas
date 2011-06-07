program fjf793f;

label External;

begin
  var a: String (2) = 'OK';
  External: WriteLn (a);
  if False then goto External
end.
