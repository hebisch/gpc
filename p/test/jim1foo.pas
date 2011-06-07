MODULE jim1fb Interface;        { INTERFACE }
 EXPORT catch22 = (footype,setfoo,getfoo);
  TYPE footype = integer;
 PROCEDURE setfoo(f: footype);
  FUNCTION  getfoo: footype;
END. { module jim1foobar interface }

MODULE jim1fb Implementation;   { IMPLEMENTATION }
 IMPORT StandardInput;
      StandardOutput;
 VAR foo : footype;
 { Note: the effect is the same as the Forward directive would have:
    parameter lists and return types are not "allowed" in the declaration
    of exported routines. }
  PROCEDURE setfoo;
 BEGIN
    foo := f;
 END;
  FUNCTION getfoo;
  BEGIN
    getfoo := foo;
  END;
 TO BEGIN DO
    BEGIN
      foo := 59;
{      writeln ('Just an example of a module initializer. See comment below'); }
   END;
  TO END DO
   BEGIN
     foo := 0;
{     writeln ('Goodbye'); }
   END;
END. { jim1fb implementation }
