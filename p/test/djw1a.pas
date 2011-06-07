PROGRAM arr_test(input,output);

TYPE arrtype = ARRAY [-10..10] OF double;

VAR  test : arrtype;

PROCEDURE init(VAR arr: arrtype);

  VAR i : integer;

  BEGIN
     FOR i:= -10 TO 10 DO arr[i]:= i*2.0;
     
     i:= 0; arr[i]:= 1.0; { This is OK }
     
     arr[0]:= 1.0; { This causes an arithmetical error at compile time }
  END;

BEGIN
   init(test);
   test[0]:= 1.0;
   if test[0] = 1 then WriteLn ('OK')
END.
