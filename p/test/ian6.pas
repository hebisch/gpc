program cpptest(input,output);

begin

#ifdef __GPC__
        writeln('#ifdef __GPC__');
#endif

#if defined (__GPC__)
        writeln('defined (__GPC__)');
#endif
end.
