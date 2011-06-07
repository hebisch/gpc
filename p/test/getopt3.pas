{ Test of the GetOpt functions. (Very similar to GetOptDemo.) }

program GetOptTest;

uses GPC;

var
  ch : Char;
  i, LongIndex : Integer;

const
  LongOptions : array [1 .. 4] of OptionType =
    (('abc',    NoArgument,       nil, 'x'),
     ('noarg',  NoArgument,       nil, 'n'),
     ('reqarg', RequiredArgument, nil, 'r'),
     ('optarg', OptionalArgument, nil, 'o'));

begin
  LongIndex := - 1;
  GetOptErrorFlag := True;
  repeat
    ch := GetOptLong ('', LongOptions, LongIndex, True);
    case ch of
      EndOfOptions  : Break;
      NoOption      : Write ('no-option argument');
      UnknownOption : if UnknownOptionCharacter = UnknownLongOption
                        then Write ('(incorrect long option)')
                        else Write ('unknown option `', UnknownOptionCharacter, '''');
      LongOption    : with LongOptions [LongIndex] do
                        Write ('long option `', CString2String (OptionName), '''');
      else            Write ('option `', ch, '''')
    end;
    if HasOptionArgument
      then WriteLn (' with argument `', OptionArgument, '''')
      else WriteLn
  until False;
  if (FirstNonOption < 1) or (FirstNonOption > ParamCount + 1) then
    begin
      WriteLn (StdErr, 'Internal error with FirstNonOption.');
      Halt (2)
    end;
  if FirstNonOption <= ParamCount then WriteLn ('Remaining arguments:');
  for i := FirstNonOption to ParamCount do WriteLn (ParamStr (i))
end.
