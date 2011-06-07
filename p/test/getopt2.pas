{ Test of the GetOpt functions. (Very similar to GetOptDemo.) }

program GetOptTest;

uses GPC;

var
  ch, LongOptFlag : Char;
  i, LongIndex : Integer;

const
  LongOptions : array [1 .. 4] of OptionType =
    (('abc',    NoArgument,       nil,          'x'),
     ('noarg',  NoArgument,       @LongOptFlag, #2),
     ('reqarg', RequiredArgument, @LongOptFlag, #3),
     ('optarg', OptionalArgument, @LongOptFlag, #4));

begin
  LongIndex := - 1;
  GetOptErrorFlag := True;
  repeat
    ch := GetOptLong ('nr:o::-', LongOptions, LongIndex, True);
    case ch of
      EndOfOptions  : Break;
      NoOption      : Write ('no-option argument');
      UnknownOption : if UnknownOptionCharacter = UnknownLongOption
                        then Write ('(incorrect long option)')
                        else Write ('unknown option `', UnknownOptionCharacter, '''');
      LongOption    : with LongOptions [LongIndex] do
                        begin
                          Write ('long option `', CString2String (OptionName), '''');
                          if Ord (LongOptFlag) <> LongIndex then
                            Write (' <internal error> ')
                        end;
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
