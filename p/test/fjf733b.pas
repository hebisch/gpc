{ NOTE: You do not want to disable basic keywords such as `type'.
  This is only a stupid example. You have been warned! }

{$disable-keyword tYPe}  { casing is irrelevant, of course }

program fjf733b;

var
  Type: String (2);

begin
  Type := 'OK';
  WriteLn (Type)
end.
