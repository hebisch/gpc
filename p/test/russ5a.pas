program russ5a;
begin
   if  Paramstr( ParamCount ) = 'foo' then
   begin
     writeln('Quitting: output file "', Paramstr( ParamCount ), '" exists');
     break; { WRONG }
   end;
end.
