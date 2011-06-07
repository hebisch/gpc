{

 This program tests arrays with predefined values.
 'Necessary' to build lex/yacc with gpc.

}

{ FIXED: Initialization of an array of strings did not work. }

{$W-}  { ignoring indices and field names in initializers }

program Test(output);

const
  no_of_keywords = 12;
  id_len         =  20;
type
  Ident =  string(id_len);
var
{ table of Pascal keywords: }
  keyword : array [1..no_of_keywords] of Ident value [
    1:'BEGIN'; 2:'CONST'; 3:'END'; 4:'EXPORT'; 5:'FUNCTION';
    6:'IMPLEMENTATION'; 7:'IMPORT'; 8:'INTERFACE';
    9:'MODULE'; 10:'PROCEDURE'; 11:'TYPE'; 12:'VAR'];

begin
  writeln('OK');
end.
