program PCErrorR;

var
ch :char;
ch1 :array[1..10] of char;

begin
ch:=ch1[127 + 1]  { WRONG }
end.
