extern FILE * deps_out_file;
extern void initialize_char_syntax (void);
extern void make_definition (const char *str, int case_sensitive);
extern int gpcpp_process_options (int argc, char **argv);
extern int gpcpp_main (const char *filename, FILE * in_file);
extern int gpcpp_writeout (const char *out_filename, FILE * out_file);
extern int gpcpp_fillbuf (char * buf, int max_size);
