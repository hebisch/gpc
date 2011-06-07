program russ5b;
begin
   if  Paramstr( ParamCount ) = 'foo' then
   begin
     writeln('Quitting: output file "', Paramstr( ParamCount ), '" exists');
     continue; { WRONG }
   end;
end.
