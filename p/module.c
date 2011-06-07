/*Module support for GNU Pascal

  Copyright (C) 1994-2006, Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Alexei Volokhov <voh@ispras.ru>
           Jan-Jaap van der Heijden <j.j.vanderheijden@student.utwente.nl>
           Frank Heckenbach <frank@pascal.gnu.de>
           Waldek Hebisch <hebisch@math.uni.wroc.pl>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA. */

#include "gpc.h"
#include "p/p-version.h"
#ifdef GCC_4_0
#include "version.h"
#endif

#ifdef EGCS
#define HOST_PTR_PRINTF_CAST_TYPE PTR
#else
#define HOST_PTR_PRINTF_CAST_TYPE HOST_WIDE_INT
#endif

#ifdef GCC_4_1
#define GPC_HOST_PTR_PRINTF "%p"
#else
#define GPC_HOST_PTR_PRINTF HOST_PTR_PRINTF
#endif

#ifdef EGCS97

/* By default there is no special suffix for target executables.  */
/* FIXME: when autoconf is fixed, remove the host check - dj */
#if defined(TARGET_EXECUTABLE_SUFFIX) && defined(HOST_EXECUTABLE_SUFFIX)
#define HAVE_TARGET_EXECUTABLE_SUFFIX
#else
#undef TARGET_EXECUTABLE_SUFFIX
#define TARGET_EXECUTABLE_SUFFIX ""
#endif

/* By default there is no special suffix for host executables.  */
#ifdef HOST_EXECUTABLE_SUFFIX
#define HAVE_HOST_EXECUTABLE_SUFFIX
#else
#define HOST_EXECUTABLE_SUFFIX ""
#endif

/* By default, the suffix for target object files is ".o".  */
#ifdef TARGET_OBJECT_SUFFIX
#define HAVE_TARGET_OBJECT_SUFFIX
#else
#define TARGET_OBJECT_SUFFIX ".o"
#endif

#else

/* By default there is no special suffix for target executables.  */
#if defined (EXECUTABLE_SUFFIX) && !defined (__DJGPP__)
#define HAVE_TARGET_EXECUTABLE_SUFFIX
#define TARGET_EXECUTABLE_SUFFIX EXECUTABLE_SUFFIX
#else
#undef TARGET_EXECUTABLE_SUFFIX
#define TARGET_EXECUTABLE_SUFFIX ""
#endif

/* By default there is no special suffix for host executables.  */
#ifdef EXECUTABLE_SUFFIX
#define HAVE_HOST_EXECUTABLE_SUFFIX
#define HOST_EXECUTABLE_SUFFIX EXECUTABLE_SUFFIX
#else
#define HOST_EXECUTABLE_SUFFIX ""
#endif

/* By default, the suffix for target object files is ".o".  */
#ifdef OBJECT_SUFFIX
#define HAVE_TARGET_OBJECT_SUFFIX
#define TARGET_OBJECT_SUFFIX OBJECT_SUFFIX
#else
#define TARGET_OBJECT_SUFFIX ".o"
#endif

#endif

typedef struct
{
  char *filename;
  size_t size, curpos;
  unsigned char *buffer;
} MEMFILE;

static MEMFILE *mopen_read (const char *);
static void mread1 (MEMFILE *, PTR, size_t);
static void mseek (MEMFILE *, size_t);
static void add_to_automake_temp_file (const char *);
static const char *quote_arg (const char *);
static int execute (const char *, char *);
static char *locate_file_1 (const char *, const char *);
static const char *get_automake_switches (int);
static struct interface_table_t *get_interface_table (tree, tree);
static gpi_int compute_checksum (unsigned char *, gpi_int);
static int itab_check_gpi_checksum (tree, gpi_int, int);
static const char *file_basename (const char *);
static int find_automake_tempfile_entry (const char *, const char *, int);
static char *locate_object_file (const char *);
static int module_must_be_recompiled (tree, char *, char *, tree);
static char *locate_interface_source (const char *, const char *, const char *);
static MEMFILE *gpi_open (tree, const char *, const char *, int, gpi_int *, gpi_int *, gpi_int *);
static tree load_gpi_file (tree, const char *, int);
static void import_node (tree, tree, tree, import_type);
static void load_own_interface (int);
static module_t find_module (tree, int);
static void module_expand_exported_ranges (tree);
static char *load_string (MEMFILE *);
static inline void store_length_f (FILE *, const void *, size_t);
static void store_length (const void *, size_t);
static void start_chunk (FILE *, int, gpi_int);
static void store_string_chunk (FILE *, int, const char *);
static inline void store_string (const char *);
static tree dequalify_id (tree);
static void store_tree (tree, FILE *, tree);
static int get_node_id (tree);
static void store_node (tree);
static void store_node_fields (tree, int);
static tree load_tree (MEMFILE *, gpi_int, gpi_int, int);
static tree load_node (void);
static void itab_store_node (struct interface_table_t *, gpi_int, tree);
static void store_flags (tree);

/* Start GPI info (the following defines are used by gpidump.pas via tree.inc) */
#define GPI_HEADER "GNU Pascal unit/module interface\n"
#define GPI_DEBUG_KEY 0x54637281
#define GPI_ENDIANNESS_MARKER 0x12345678
#define GPI_INVERSE_ENDIANNESS_MARKER 0x78563412

#define GPI_CHUNKS \
  GPI_CHUNK (GPI_CHUNK_INVALID,        0, 0, "invalid chunk"), \
  GPI_CHUNK (GPI_CHUNK_VERSION,        1, 1, "version"), \
  GPI_CHUNK (GPI_CHUNK_TARGET,         1, 1, "target"), \
  GPI_CHUNK (GPI_CHUNK_MODULE_NAME,    1, 1, "module name"), \
  GPI_CHUNK (GPI_CHUNK_SRCFILE,        1, 1, "source file name"), \
  GPI_CHUNK (GPI_CHUNK_IMPORT,         0, 0, "name of imported interface"), \
  GPI_CHUNK (GPI_CHUNK_LINK,           0, 0, "name of file to be linked"), \
  GPI_CHUNK (GPI_CHUNK_LIB,            0, 0, "name of library to be linked"), \
  GPI_CHUNK (GPI_CHUNK_INITIALIZER,    0, 0, "module initializer"), \
  GPI_CHUNK (GPI_CHUNK_GPC_MAIN_NAME,  0, 1, "main function name"), \
  GPI_CHUNK (GPI_CHUNK_NODES,          1, 1, "tree nodes"), \
  GPI_CHUNK (GPI_CHUNK_OFFSETS,        1, 1, "offset table"), \
  GPI_CHUNK (GPI_CHUNK_IMPLEMENTATION, 0, 1, "implementation flag")

#define SPECIAL_NODES \
  SN (null_tree_node) \
  SN (error_mark_node) \
  SN (pascal_integer_type_node) \
  SN (short_integer_type_node) \
  SN (integer_type_node) \
  SN (long_integer_type_node) \
  SN (long_long_integer_type_node) \
  SN (ptrsize_integer_type_node) \
  SN (pascal_cardinal_type_node) \
  SN (short_unsigned_type_node) \
  SN (unsigned_type_node) \
  SN (long_unsigned_type_node) \
  SN (long_long_unsigned_type_node) \
  SN (ptrsize_unsigned_type_node) \
  SN (ptrdiff_type_node) \
  SN (char_type_node) \
  SN (float_type_node) \
  SN (double_type_node) \
  SN (long_double_type_node) \
  SN (complex_double_type_node) \
  SN (intQI_type_node) \
  SN (intHI_type_node) \
  SN (intSI_type_node) \
  SN (intDI_type_node) \
  SN (unsigned_intQI_type_node) \
  SN (unsigned_intHI_type_node) \
  SN (unsigned_intSI_type_node) \
  SN (unsigned_intDI_type_node) \
  SN (void_type_node) \
  SN (void_list_node) \
  SN (open_array_index_type_node) \
  SN (ptr_type_node) \
  SN (const_ptr_type_node) \
  SN (integer_zero_node) \
  SN (null_pointer_node) \
  SN (integer_one_node) \
  SN (integer_minus_one_node) \
  SN (byte_integer_type_node) \
  SN (byte_unsigned_type_node) \
  SN (boolean_type_node) \
  SN (boolean_false_node) \
  SN (boolean_true_node) \
  SN (cstring_type_node) \
  SN (cboolean_type_node) \
  SN (byte_boolean_type_node) \
  SN (short_boolean_type_node) \
  SN (word_boolean_type_node) \
  SN (cword_boolean_type_node) \
  SN (long_boolean_type_node) \
  SN (long_long_boolean_type_node) \
  SN (wchar_type_node) \
  SN (sizetype) \
  SN (ssizetype) \
  SN (usizetype) \
  SN (bitsizetype) \
  SN (sbitsizetype) \
  SN (ubitsizetype) \
  SN (untyped_file_type_node) \
  SN (text_type_node) \
  SN (any_file_type_node) \
  SN (complex_type_node) \
  SN (pascal_maxint_node) \
  SN (input_variable_node) \
  SN (output_variable_node) \
  SN (error_variable_node) \
  SN (string_schema_proto_type) \
  SN (const_string_schema_proto_type) \
  SN (const_string_schema_par_type) \
  SN (string255_type_node) \
  SN (empty_set_type_node) \
  SN (char_max_node) \
  SN (real_max_node) \
  SN (real_min_node) \
  SN (real_eps_node) \
  SN (real_zero_node) \
  SN (real_half_node) \
  SN (real_pi_node) \
  SN (complex_zero_node) \
  SN (gpc_type_DateTimeString) \
  SN (gpc_type_TimeStamp) \
  SN (gpc_type_BindingType) \
  SN (gpc_type_PObjectType) \
  SN (inoutres_variable_node) \
  SN (null_pseudo_const_node)
/* End GPI info */

/* Special nodes. The array index is the uid number in the GPI file. */
#define SN(NODE) &NODE,
static const tree null_tree_node = NULL_TREE;
static const tree *const special_nodes[] = { SPECIAL_NODES NULL };
#define NUM_SPECIAL_NODES (ARRAY_SIZE (special_nodes) - 1)

/* Code USE_GPI_DEBUG_KEY into the header since GPI files with and without it
   are not compatible. Also add the GCC version (in gpi_version_string). */
#ifdef USE_GPI_DEBUG_KEY
#define GPI_VERSION_ADDITION " D "
#else
#define GPI_VERSION_ADDITION " "
#endif
static const char *gpi_version_string = NULL;

/* HASH_FUNC must avoid negative values. */
#define MAX_HASH_TABLE 16381
#define HASH_FUNC(NODE) (abs ((NODE) - NULL_TREE) % MAX_HASH_TABLE)

/* Codes used in the chunks of GPI files */
#define GPI_CHUNK(ID, REQUIRED, UNIQUE, NAME) ID
enum { GPI_CHUNKS, NUM_GPI_CHUNKS };
#undef GPI_CHUNK
#define GPI_CHUNK(ID, REQUIRED, UNIQUE, NAME) NAME
static const char *const gpi_chunk_names[NUM_GPI_CHUNKS] = { GPI_CHUNKS };

/* A list of all modules contained in this source file. */
static GTY(()) module_t module_list = NULL_MODULE;

/* The module we are currently compiling. */
module_t current_module;

/* Files to be linked seen outside of any module. */
static string_list *pending_link_files = NULL;

/* Options to pass to child gpc processes in automake. */
static char *automake_gpc_options = NULL;

/* A table holding the nodes imported from all GPI files
   together with their UIDs, so duplicates can be identified. */
struct interface_table_t GTY(())
{
  tree interface_name;
  tree module_name;
  gpi_int gpi_checksum;
  tree interface_name_node;
  tree initializers;  /* Same as in module_t. Predefined interfaces
                         (StandardInput etc.) have no initializer. */
  int count;
  tree * GTY((length ("%h.count"))) nodes;
  int * GTY((length ("%h.count"))) hashlist_next;
  int hash_table[MAX_HASH_TABLE];
  struct interface_table_t *next;
};

static GTY(()) struct interface_table_t *interface_table = NULL;

static GTY(()) struct interface_table_t *current_interface_table;

#define mptr(F, O) ((F)->buffer + (O))
#define meof(F) ((F)->curpos >= (F)->size)
#define mtell(F) ((F)->curpos)
#define mclose(F) (gcc_assert (F), free ((F)->buffer), free ((F)->filename), free (F))

static MEMFILE *
mopen_read (const char *name)
{
  struct stat finfo;
  MEMFILE *s = NULL;
  FILE *the_file = fopen (name, "rb");
  if (the_file)
    {
      if (fstat (fileno (the_file), &finfo) == 0)
        {
          s = (MEMFILE *) xmalloc (sizeof (MEMFILE));
          s->size = finfo.st_size;
          s->curpos = 0;
          s->buffer = (unsigned char *) xmalloc (s->size);
          if (fread (s->buffer, 1, s->size, the_file) == s->size)
            s->filename = save_string (name);
          else
            {
              free (s->buffer);
              free (s);
              s = NULL;
            }
        }
      fclose (the_file);
    }
  return s;
}

static void
mread1 (MEMFILE *F, PTR P, size_t S)
{
  if (F->curpos + S > F->size)
    {
      error ("unexpected end of file in `%s'", F->filename);
      exit (FATAL_EXIT_CODE);
    }
  memcpy (P, F->buffer + F->curpos, S);
  F->curpos += S;
}

static void
mseek (MEMFILE *F, size_t O)
{
  gcc_assert (O <= F->size);
  F->curpos = O;
}

/* Scan the program/module parameter list for entries of file type.
   If this is at top level, and they are variables of file type, flag the files as external.
   Since the order of declarations is relaxed, this is checked before every routine.
   All nodes already handled are marked. */
void
associate_external_objects (tree external_name_list)
{
  tree link;
  if (external_name_list && pascal_global_bindings_p ())
    for (link = external_name_list; link; link = TREE_CHAIN (link))
      {
        tree id = TREE_VALUE (link), name;
        int found = 1;
        if (!id)
          found = 0;
        else if (IDENTIFIER_IS_BUILT_IN (id, p_Output))
          {
            current_module->output_available = 1;
            pushdecl_import (output_variable_node, 0);
          }
        else if (IDENTIFIER_IS_BUILT_IN (id, p_Input))
          {
            current_module->input_available = 1;
            pushdecl_import (input_variable_node, 0);
          }
        else if (IDENTIFIER_IS_BUILT_IN (id, p_StdErr) && !(co->pascal_dialect & C_E_O_PASCAL))
          pushdecl_import (error_variable_node, 0);
        else if ((name = lookup_name (id)))
          {
            if (TREE_CODE (name) == VAR_DECL && PASCAL_TYPE_FILE (TREE_TYPE (name)))
              PASCAL_EXTERNAL_OBJECT (name) = 1;
            else if (co->pascal_dialect & CLASSIC_PASCAL)
              error (
                "identifier `%s' in %s heading is not a variable of file type",
                       IDENTIFIER_NAME (id),
                       current_module->main_program ? "program" : "module");
            else
              gpc_warning (
                "identifier `%s' in %s heading is not a variable of file type",
                IDENTIFIER_NAME (id),
                current_module->main_program ? "program" : "module");
          }
        else
          found = 0;
        if (found)
          TREE_VALUE (link) = NULL_TREE;
      }
}

/* Make sure all the names in program/module param list have been declared. */
void
check_external_objects (tree idlist)
{
  associate_external_objects (idlist);
  for (; idlist; idlist = TREE_CHAIN (idlist))
    if (TREE_VALUE (idlist))
      error ("identifier `%s' in %s heading is undefined", IDENTIFIER_NAME (TREE_VALUE (idlist)),
             current_module->main_program ? "program" : "module");
}

/* Locate a module by its NAME.
   If CREATE is nonzero, create a new module if an old one is not found. */
static module_t
find_module (tree name, int create)
{
  module_t curr;
  for (curr = module_list; curr; curr = curr->next)
    if (curr->name == name)
      return curr;
  if (create)
    {
#ifdef EGCS97
#ifndef GCC_3_3
      curr = (module_t) xmalloc (sizeof (struct module));
#else
      curr = (module_t) ggc_alloc (sizeof (struct module));
#endif
#else
      curr = (module_t) obstack_alloc (&permanent_obstack, sizeof (struct module));
#endif
      /* Initialize */
      memset ((void *) curr, 0, sizeof (struct module));
      curr->name = name;
      curr->next = module_list;
      curr->link_files = pending_link_files;
      pending_link_files = NULL;
      module_list = curr;
#if defined (EGCS97) && !defined (GCC_3_3)
      ggc_add_tree_root (&(curr->MODULE_T_FIRST_TREE_FIELD),
        (&(curr->MODULE_T_LAST_TREE_FIELD) - &(curr->MODULE_T_FIRST_TREE_FIELD)) + 1);
#endif
    }
  return curr;
}

/* Allocate and initialize a new structure for a new program (kind = 0),
   unit (1), interface (2), implementation (3) or GPC (4) module named id. */
void
initialize_module (tree id, tree par, int kind)
{
  const char *n;
  const char *current_module_name = NULL;
  if (kind == 1)
    chk_dialect ("units are", U_B_D_M_PASCAL);
  else if (kind == 2 || kind == 3)
    chk_dialect ("modules are", E_O_PASCAL);
  else if (kind == 4)
    chk_dialect ("this form of modules is", GNU_PASCAL);
  if (!id)
    {
      if (!co->pascal_dialect)
        gpc_warning ("missing program header");
      else  /* BP does not even warn */
        chk_dialect ("programs without program header are", B_D_PASCAL);
      id = get_identifier ("noname");
    }
  current_module = find_module (id, 1);
  current_module->bp_qualids = id && (kind == 1 || (kind == 0 && (co->pascal_dialect & B_D_PASCAL)));
  if (current_module->bp_qualids)
    pushdecl (build_decl (NAMESPACE_DECL, id, void_type_node));
  current_module->assembler_name = NULL;
  if (kind == 0)
    {
      string_list *link_file;
      for (link_file = current_module->link_files; link_file; link_file = link_file->next)
        add_to_automake_temp_file (link_file->string);
      current_module->main_program = current_module->implementation = 1;
      current_module_name = "_p__M0";
      current_module->assembler_name = get_identifier (current_module_name);
    }
  if (par)
    {
      tree t;
      if (TREE_VALUE (par) && TREE_CODE (TREE_VALUE (par)) == TREE_LIST)
        {
          current_module->parms = TREE_VALUE (par);
          check_duplicate_id (current_module->parms);
          associate_external_objects (current_module->parms);
        }
      for (t = TREE_PURPOSE (par); t; t = TREE_CHAIN (t))
        if (IDENTIFIER_IS_BUILT_IN (TREE_PURPOSE (t), p_name)
            && TREE_VALUE (t) && list_length (TREE_VALUE (t)) == 1)
          {
            current_module->assembler_name = check_assembler_name (TREE_VALUE (TREE_VALUE (t)));
            current_module_name = IDENTIFIER_POINTER (current_module->assembler_name);
          }
        else
          error ("unknown module attribute `%s'", IDENTIFIER_NAME (TREE_PURPOSE (t)));
    }
  if (!current_module->assembler_name)
    {
      char name_len[23];
      const char *mname = IDENTIFIER_POINTER (current_module->name);
      sprintf (name_len, "%ld_", (long) strlen (mname));
      current_module_name = ACONCAT (("_p__M", name_len, mname, NULL));
      current_module->assembler_name = get_identifier (current_module_name);
    }
  n = ACONCAT ((current_module_name, "_init", NULL));
  current_module->initializers = build_tree_list (NULL_TREE, get_identifier (n));
  n = ACONCAT ((current_module_name, "_fini", NULL));
  current_module->finalizer = build_implicit_routine_decl (get_identifier (n),
    void_type_node, void_list_node, ER_STATIC);

  if (kind != 0)
    pushlevel (0);
  /* Unit autoexport */
  if (kind == 1)
    export_interface (current_module->name, build_tree_list (NULL_TREE, NULL_TREE));
  if (kind == 3)
    load_own_interface (1);
}

void
start_module_interface (void)
{
  const char *n = ACONCAT ((IDENTIFIER_POINTER (current_module->name), "-all", NULL));
  tree t = build_tree_list (NULL_TREE, NULL_TREE);
  TREE_PRIVATE (t) = 1;
  export_interface (get_identifier (n), t);
}

void
start_unit_implementation (void)
{
  if (!co->implementation_only)
    create_gpi_files ();
  if (co->interface_only)
    exit_compilation ();
  /* Make sure that interface nodes keep their identity by reloading the
     GPI files previously created (presumably) with `--interface_only'. This
     is the same as with separate interface and implementation modules. */
      module_t m = current_module;
      clear_forward_decls ();  /* don't complain in poplevel */
      finalize_module (1);
      current_module = m;
      pushlevel (0);
      load_own_interface (0);
  current_module->implementation = 1;
}

void
finalize_module (int implementation_follows)
{
  if (co->implementation_only && co->automake_level)
    gpc_warning ("`--automake' together with `--implementation-only' can cause problems");
  if (errorcount || sorrycount)
    exit_compilation ();
  if (!implementation_follows /* && !co->implementation_only */)
    {
      /* Extend GPI files to contain additional information from
         the implementation part. */
      tree escan;
      int in_implementation = current_module->implementation;
      if (in_implementation || current_module->link_files || gpc_main)
      for (escan = current_module->exports; escan; escan = TREE_CHAIN (escan))
        {
          FILE *s;
          char *p;
          tree name = TREE_VALUE (escan);
          string_list *link_file;
          char *current_gpi_file_name = ACONCAT ((IDENTIFIER_POINTER (name), ".gpi", NULL));
          for (p = current_gpi_file_name; *p; p++)
            *p = TOLOWER (*p);
          if (gpi_destination_path)
            current_gpi_file_name = ACONCAT ((gpi_destination_path, current_gpi_file_name, NULL));
          s = fopen (current_gpi_file_name, "ab");
          if (!s)
            {
              error ("cannot append to GPI file `%s'", current_gpi_file_name);
              exit (FATAL_EXIT_CODE);
            }
          if (co->debug_gpi)
            fprintf (stderr, "extending GPI file: %s\n", current_gpi_file_name);
          if (in_implementation)
            store_string_chunk (s, GPI_CHUNK_IMPLEMENTATION, "");
          /* Store additional names of files to be linked. */
          for (link_file = current_module->link_files; link_file; link_file = link_file->next)
            if (link_file->string[0] == '-')
              store_string_chunk (s, GPI_CHUNK_LIB, link_file->string);
            else
              store_string_chunk (s, GPI_CHUNK_LINK, file_basename (link_file->string));
          if (gpc_main)
            store_string_chunk (s, GPI_CHUNK_GPC_MAIN_NAME, gpc_main);
          fclose (s);
        }
    }

  if (current_module->implementation)
    implicit_module_structors ();
  check_external_objects (current_module->parms);
  current_module->imports = NULL_TREE;
  /* This `if' might be a kludge (chief47*.pas etc.), but it should
     get irrelevant with gp, anyway. (?) */
  if (implementation_follows)
    poplevel (0, 0, 0);
  else
    current_module->exports = NULL_TREE;
  current_module->autoexport = NULL_TREE;
  current_module->implementation = 0;
  current_module->interface = 0;
  current_module->output_available = 0;
  current_module->input_available = 0;
  current_module = NULL_MODULE;
  exported_interface_list = NULL_TREE;
#ifndef GCC_3_3
  while (interface_table)
    {
      struct interface_table_t *next_interface = interface_table->next;
#ifdef EGCS97
      ggc_del_root (&(interface_table->interface_name));
      ggc_del_root (&(interface_table->module_name));
      ggc_del_root (&(interface_table->interface_name_node));
      ggc_del_root (&(interface_table->initializers));
#endif
      free (interface_table->nodes);
      free (interface_table->hashlist_next);
      free (interface_table);
      interface_table = next_interface;
    }
#else
  interface_table = NULL;
#endif

  if (implementation_follows && co->interface_only)
    exit_compilation ();
}

/* Open a new interface NAME for the current module. EXPORT_LIST
   contains the names that should be exported by this interface.

   Later, after the interface lists have been filled, they will be
   written to GPI files by create_gpi_files() below.

   NAME is an IDENTIFIER_NODE of the exported interface name.

   EXPORT_LIST is a TREE_LIST containig:
     export "all" marker (TREE_PURPOSE == NULL_TREE, TREE_VALUE == NULL_TREE)
     explicit exports
     end of explictit exports marker (TREE_PURPOSE == integer_zero_node,
                 TREE_VALUE == NULL_TREE)
     implicit ("all") exports

   normal export entries:
   TREE_READONLY: protected
   TREE_PURPOSE: Export renaming (new name) or NULL_TREE.
   TREE_VALUE: IDENTIFIER_NODE of the exported name
     or TREE_LIST if exporting a range (TREE_PURPOSE .. TREE_VALUE)

   Later in `module_expand_exported_ranges' we replace the TREE_LIST
   representing a range by NULL_TREE and we add entries for the individual
   values instead. */
void
export_interface (tree name, tree export_list)
{
  tree exported, t;

  for (exported = current_module->exports; exported; exported = TREE_CHAIN (exported))
    if (TREE_VALUE (exported) == name)
      {
        error ("interface `%s' has already been exported", IDENTIFIER_NAME (name));
        return;
      }

  exported_interface_list = tree_cons (NULL_TREE, name, exported_interface_list);
  current_module->exports = chainon (current_module->exports, build_tree_list (export_list, name));

  /* Allow `all', also as part of an export list which may contain additional
     exports, but also rename and/or qualify some of the `all' exports.
     The latter works because handle_autoexport joins the autoexported names
     at the end, and store_tree handles the list in order, ignoring duplicates.
     So the explicit exports take precendence. This is a bit fragile. */
  for (t = export_list; t && TREE_VALUE (t); t = TREE_CHAIN (t)) ;
  if (t)
    {
      tree last = tree_last (export_list);
      /* Mark end of explicit exports */
      TREE_CHAIN (last) = build_tree_list (integer_zero_node, NULL_TREE);
      last = TREE_CHAIN (last);
      current_module->autoexport = chainon (current_module->autoexport,
        build_tree_list (last, build_tree_list (export_list, name)));
    }
}

/* Import module/unit interfaces specified on the command line via `--uses=...'. */
void
do_extra_import (void)
{
  char *p = extra_imports;
  if (!p)
    return;
  while (*p)
    {
      char *buffer = alloca (strlen (p) + 1), *q = buffer;
      tree interface_name, file_name;
      while (*p &&
             ((*p >= 'A' && *p <= 'Z')
              || (*p >= 'a' && *p <= 'z')
              || (*p >= '0' && *p <= '9')
              || (*p == '_')))
        {
          if (q == buffer)
            *q = TOUPPER (*p);
          else
            *q = TOLOWER (*p);
          p++;
          q++;
        }
      *q = 0;
      interface_name = get_identifier (buffer);
      if (*p == '(')
        {
          q = buffer;
          p++;
          while (*p && *p != ')')
            {
              *q = *p;
              p++;
              q++;
            }
          *q = 0;
          if (*p == ')')
            p++;
          else
            gpc_warning ("missing `)' in `--uses' parameter");
          file_name = build_string_constant (buffer, q - buffer, 0);
        }
      else
        file_name = NULL_TREE;
      import_interface (interface_name, NULL_TREE, IMPORT_USES, file_name);
      while (*p
             && !((*p >= 'A' && *p <= 'Z')
                  || (*p >= 'a' && *p <= 'z')
                  || (*p >= '0' && *p <= '9')
                  || (*p == '_')))
        {
          if (*p != ',')
            gpc_warning ("missing `,' in `--uses' parameter");
          p++;
        }
    }
}

/* Export names of a Borland Pascal unit. This also handles
   `export foo = all' clauses and perhaps, one day, PXSC modules. */
void
handle_autoexport (tree name)
{
  tree e;
  if (!current_module->implementation)
    for (e = current_module->autoexport; e; e = TREE_CHAIN (e))
      {
        /* TREE_PURPOSE (e) serves as a pointer to the tail of the list stored
           in TREE_PURPOSE (TREE_VALUE (e)), to allow for fast appending at the
           end. The export list may contain duplicates (see store_tree), so
           don't bother checking which would be O(n^2). There shouldn't be any
           at this point, anyway. */
        tree t = build_tree_list (NULL_TREE, name);
        TREE_CHAIN (TREE_PURPOSE (e)) = t;
        TREE_PURPOSE (e) = t;
      }
}

/* The automake facility

   When invoked with an `--automake' or `--autobuild' option,
   GPC can do an implicit `make' for preprocessing, compiling,
   and linking. A Makefile is not needed; everything is
   extracted from the Pascal source.

   This will be replaced by an external utility `gp' soon. */

#ifndef EGCS
/* pexecute.c needs this function */
extern const char *my_strerror (int);
const char *
my_strerror (int e)
{
#ifdef HAVE_STRERROR
  return strerror (e);
#else
  static char buffer[30];
  if (!e)
    return "cannot access";
  if (e > 0 && e < sys_nerr)
    return sys_errlist[e];
  sprintf (buffer, "Unknown error %d", e);
  return buffer;
#endif
}
#define xstrerror my_strerror
#endif

/* Also in gpc.c :-( */
static const char *
quote_arg (const char *str)
{
  int need_quoting = 0;
  const char *p = str, *q;
  char *r;
  for (q = p; *q && !need_quoting; q++)
    need_quoting = *q == ' ' || *q == '\\';
  if (need_quoting)
    {
      p = r = xmalloc (2 * strlen (str) + 1);
      for (q = str; *q; q++)
        {
          if (*q == ' ' || *q == '\\')
            *r++ = '\\';
          *r++ = *q;
        }
      *r++ = 0;
    }
  else
    p = str;
  return p;
}

/* JJ 970809: rewritten to utilize standard pexecute() and pwait() calls

   For the automake facility we need to execute gpc as a child
   process. execute() acts as an interface to the underlying
   pexecute() and pwait() functions borrowed from GCC or libiberty.

   Return 1 on success, 0 otherwise. */
static int
execute (const char *what, char *args)
{
  char *s;
  int pid, wait_status;
  int i;
  const char **argv;
  char *errmsg_fmt, *errmsg_arg;
  char *temp_base = choose_temp_base ();

  /* With `--debug-automake', print what we are about to do, and maybe query. */
  if (co->debug_automake)
    {
      fprintf (stderr, "GPC automake: %s %s\n", what, args);
#ifdef DEBUG
      fprintf (stderr, "\nGo ahead? (y or n) ");
      fflush (stderr);
      i = getchar ();
      if (i != '\n')
        while (getchar () != '\n') ;
      if (i != 'y' && i != 'Y')
        return 0;
#endif
    }

  /* Count the args (upper estimate) */
  i = 0;
  for (s = args; *s; s++)
    if (*s == ' ')
      i++;
  i++;
  argv = alloca (sizeof (const char *) * (i + 3));

  i = 0;
  argv[i++] = what;

  s = args;
  while (1)
    {
      argv[i++] = s;
      for (; *s && *s != ' '; s++)
        if (*s == '\\' && s[1])
          {
            /* remove `\'; s will step over the following character if it's a space! */
            /* `strcpy (s, s + 1);' might not work since strings overlap */
            char *a;
            for (a = s; *a /* sic! */ ; a++)
              *a = a[1];
          }
      if (*s == 0)
        break;
      *s++ = 0;
    }
  argv[i++] = 0;

  pid = pexecute (argv[0], (char *const *) argv, progname,
                  temp_base, &errmsg_fmt, &errmsg_arg,
                  PEXECUTE_FIRST | PEXECUTE_LAST | PEXECUTE_SEARCH);

  if (pid == -1)
    {
      int errno_val = errno;
      fprintf (stderr, "%s: ", progname);
      fprintf (stderr, errmsg_fmt, errmsg_arg);
      fprintf (stderr, ": %s\n", xstrerror (errno_val));
      exit (FATAL_EXIT_CODE);
    }

  pid = pwait (pid, &wait_status, 0);
  if (co->debug_automake)
    fprintf (stderr, "GPC automake: done\n");
  if (pid == -1)
    {
      fprintf (stderr, "%s: wait: %s\n", progname, xstrerror (errno));
      exit (FATAL_EXIT_CODE);
    }
  else if (WIFSIGNALED (wait_status))
    {
      fprintf (stderr, "%s: subprocess got fatal signal %d\n", progname, WTERMSIG (wait_status));
      exit (FATAL_EXIT_CODE);
    }
  else if (WIFEXITED (wait_status))
    {
      if (WEXITSTATUS (wait_status) != 0)
        {
          fprintf (stderr, "%s: %s exited with status %d\n", progname, what, WEXITSTATUS (wait_status));
          exit (WEXITSTATUS (wait_status));
        }
      return 1;
    }
  gcc_unreachable ();
}

/* Subroutine of locate_file */
static char *
locate_file_1 (const char *filename, const char *p)
{
  if (p)
    while (*p)
      {
        const char *pathname = p, *q = p;
        char *new_filename;
        int l_pathname;
        while (*q && *q != PATH_SEPARATOR)
          q++;
        if (*q)
          p = q + 1;
        else
          p = q;
        if (q > pathname + 1 && IS_DIR_SEPARATOR (q[-1]))
          q--;
        l_pathname = q - pathname;
        if (l_pathname == 0)
          l_pathname = 1;
        new_filename = xmalloc (l_pathname + 1 + strlen (filename) + 1);
        if (q == pathname)
          new_filename[0] = '.';
        else
          strncpy (new_filename, pathname, l_pathname);
        new_filename[l_pathname] = DIR_SEPARATOR;
        strcpy (new_filename + l_pathname + 1, filename);
        if (access (new_filename, R_OK) != -1)
          return new_filename;
        else
          free (new_filename);
      }
  return NULL;
}

/* Locate the file FILENAME in the relevant directories.
   Return a newly allocated char * holding the result, or NULL
   if the file is not accessible. */
char *
locate_file (const char *filename, locate_file_t kind)
{
  const char *q;
  char *r = NULL;
  if (!filename)
    return NULL;
  if (access (filename, R_OK) != -1)
    return save_string (filename);
  for (q = filename; *q && !IS_DIR_SEPARATOR (*q); q++);
  if (!*q)
    switch (kind)
    {
      /* We must search for object files compiled from units etc.
         first in unit_destination_path because, e.g., a intl.o
         (different from the Intl unit's one) exists also in the
         build directory which is in the default unit path when
         running a freshly built xgpc in the build directory. */
      case LF_OBJECT:
        if (!r) r = locate_file_1 (filename, object_path);
        if (!r && !flag_disable_default_paths) r = locate_file_1 (filename, default_object_path);
        if (!r && object_destination_path) r = locate_file_1 (filename, object_destination_path);
        /* FALLTHROUGH */
      case LF_UNIT:
        if (!r) r = locate_file_1 (filename, unit_path);
        if (!r && !flag_disable_default_paths) r = locate_file_1 (filename, default_unit_path);
        if (!r && unit_destination_path) r = locate_file_1 (filename, unit_destination_path);
        break;
      case LF_COMPILED_OBJECT:
        if (!r && object_destination_path) r = locate_file_1 (filename, object_destination_path);
        if (!r) r = locate_file_1 (filename, object_path);
        if (!r && !flag_disable_default_paths) r = locate_file_1 (filename, default_object_path);
        /* FALLTHROUGH */
      case LF_COMPILED_UNIT:
        if (!r && unit_destination_path) r = locate_file_1 (filename, unit_destination_path);
        if (!r) r = locate_file_1 (filename, unit_path);
        if (!r && !flag_disable_default_paths) r = locate_file_1 (filename, default_unit_path);
        break;
      default:
        gcc_unreachable ();
    }
  return r;
}

/* Append P to the string containing the automake GPC options. */
void
add_automake_gpc_options (const char *p)
{
  if (!automake_gpc_options)
    automake_gpc_options = save_string (p);
  else
    {
      char *q = concat (automake_gpc_options, " ", p, NULL);
      free (automake_gpc_options);
      automake_gpc_options = q;
    }
}

/* Add a line to the automake temporary file.
   The contents of that file will be passed to the linker
   and to recursive calls of the compiler. */
static void
add_to_automake_temp_file (const char *line)
{
  if (!co->automake_level)
    return;
  if (co->debug_automake)
    fprintf (stderr, "GPC automake: adding to automake temp file: %s\n", line);
  gcc_assert (automake_temp_filename);
  if (line)
    {
      FILE *automake_temp_file = fopen (automake_temp_filename, "at");
      if (!automake_temp_file)
        {
          error ("cannot append to automake temp file `%s'", automake_temp_filename);
          exit (FATAL_EXIT_CODE);
        }
      fprintf (automake_temp_file, "%s\n", line);
      fclose (automake_temp_file);
    }
}

void
append_string_list (string_list **list, const char *str, int allow_duplicates)
{
  string_list *p;
  /* Check whether str already is in the list. */
  if (!allow_duplicates)
    for (p = *list; p; p = p->next)
      if (!strcmp (p->string, str))
        return;
  p = (string_list *) xmalloc (sizeof (string_list));
  p->string = save_string (str);
  p->next = NULL;
  while (*list)
    list = &((*list)->next);
  *list = p;
}

/* Remember a FILENAME to be linked.
   This information will be written into the GPI file.
   From there, it will be read and written to the automake temp file. */
void
add_to_link_file_list (const char *filename)
{
  if (current_module && current_module->main_program)
    add_to_automake_temp_file (filename);
  else if (current_module)
    append_string_list (&current_module->link_files, filename, 0);
  else
    append_string_list (&pending_link_files, filename, 0);
}

/* Store the name of the executable to be produced in
   the automake temporary file. */
void
store_executable_name (void)
{
  if (executable_file_name)
    {
      /* Store the name of the program in the automake temp
         file, so the executable can be named after it. */
      char *name;
      if (*executable_file_name)
        ; /* accept it */
      else if (main_input_filename)
        {
          char *q = save_string (main_input_filename), *p = q + strlen (q) - 1;
          while (p > q && *p != '.')
            p--;
          if (*p == '.')
            {
              *p = 0;
              executable_file_name = q; 
            }
          else
            error("`--executable-file-name' given but input file name"
                   " have no suffix");
        }
      else
        gcc_unreachable ();
      if (executable_destination_path)
        {
          const char *p = executable_file_name + strlen (executable_file_name);
          do
            p--;
          while (p >= executable_file_name && !IS_DIR_SEPARATOR (*p));
          p++;
          name = ACONCAT (("-o ", executable_destination_path, p, TARGET_EXECUTABLE_SUFFIX, NULL));
        }
      else
        name = ACONCAT (("-o ", executable_file_name, TARGET_EXECUTABLE_SUFFIX, NULL));
      add_to_automake_temp_file (name);
    }
  else if (executable_destination_path)
    {
#ifdef HAVE_TARGET_EXECUTABLE_SUFFIX
      char *name = ACONCAT (("-o ", executable_destination_path, "a", TARGET_EXECUTABLE_SUFFIX, NULL));
#else
      char *name = ACONCAT (("-o ", executable_destination_path, "a.out", NULL));
#endif
      add_to_automake_temp_file (name);
    }
}

/* Return common flags to the automake command line.
   PASCAL_SOURCE is nonzero if GPC-specific options should be
   passed, 0 if only general GCC options are allowed.
   This function is shared by module_must_be_compiled
   and compile_module. */
static const char *
get_automake_switches (int pascal_source)
{
  const char *cmd_line = "";
  if (pascal_source)
    {
      if (co->automake_level == 1)
        cmd_line = "--autolink ";
      else if (co->automake_level == 3)
        cmd_line = "--autobuild ";
      else
        cmd_line = "--automake ";
      if (automake_gpc_options)
        cmd_line = concat (cmd_line, automake_gpc_options, " ", NULL);
      if (automake_temp_filename)
        cmd_line = concat (cmd_line, "--amtmpfile=", quote_arg (automake_temp_filename), " ", NULL);
    }
  else if (automake_gpc_options)
    {
      /* Filter out Pascal-specific options when compiling non-Pascal
         source. If the `p' subdirectory was present when `cc1' was
         compiled, this is not necessary, because then `cc1' will know
         about those options and ignore them. But we cannot rely on this. */
      char *p = automake_gpc_options, *q;
      while (*p)
        {
          while (*p == ' ' || *p == '\t')
            p++;
          /* Find the end of this option. */
          q = p;
          while (*q && *q != ' ' && *q != '\t')
            {
              if (*q == '\\' && q[1])
                q++;
              q++;
            }
          if (!(p[0] == '-' && (p[1] == '-' || p[1] == 'f' || p[1] == 'W') && is_pascal_option (p)))
            {
              /* This is not a GPC specific long option. Pass it. */
              char tmp = *q;
              *q = 0;
              cmd_line = concat (cmd_line, p, " ", NULL);
              *q = tmp;
            }
          p = q;
        }
    }
  return cmd_line;
}

static const char *
file_basename (const char *filename)
{
  const char *f = filename;
  while (*f) f++;
  while (f > filename && !IS_DIR_SEPARATOR (f[-1])) f--;
  return f;
}

static int
find_automake_tempfile_entry (const char *prefix, const char *filename, int times)
{
  FILE *automake_temp_file;
  const char *fn = file_basename (filename);
  int pl = strlen (prefix);
  gcc_assert (automake_temp_filename);
  automake_temp_file = fopen (automake_temp_filename, "rt");
  if (!automake_temp_file)
    {
      error ("cannot read automake temp file `%s'", automake_temp_filename);
      exit (FATAL_EXIT_CODE);
    }
  while (!feof (automake_temp_file))
    {
      char s[2048];
      if (fgets (s, 2048, automake_temp_file))
        {
          int l = strlen (s) - 1;
          if (s[l] == '\n')
            s[l] = 0;
          if (!strncmp (s, prefix, pl) && !strcmp (file_basename (s + pl), fn))
            times--;
        }
    }
  fclose (automake_temp_file);
  return times <= 0;
}

static char *
locate_object_file (const char *source)
{
  const char *p = file_basename (source), *q = source + strlen (source) - 1;
  while (q > p && *q != '.') q--;
  if (q > p && q[1])
    {
      char *object_filename = save_string (p), *r = object_filename + (q - p);
      r[1] = 'o';
      r[2] = 0;
      r = locate_file (object_filename, LF_COMPILED_UNIT);
      free (object_filename);
      return r;
    }
  else
    return NULL;
}

/* Check whether a module must be recompiled (for automake). */
static int
module_must_be_recompiled (tree interface_name, char *gpi_filename, char *source_name, tree import_list)
{
  char *gpc_args, *dep_filename;
  tree interface;
  FILE *dep_file;
  struct stat gpi_status, source_status;
  char *object_filename;
  char dep_line[2048];

  if (co->automake_level <= 1)  /* `--autolink' */
    return 0;

  if (co->debug_automake)
    fprintf (stderr, "checking recompilation of `%s' in `%s': ", IDENTIFIER_NAME (interface_name), gpi_filename);

  for (interface = exported_interface_list; interface; interface = TREE_CHAIN (interface))
    if (TREE_VALUE (interface) == interface_name)
      {
        if (co->debug_automake)
          fprintf (stderr, "module is in this file: 0\n");
        return 0;
      }

  if (co->automake_level > 2)
    {
      if (co->debug_automake)
        fprintf (stderr, "`--autobuild' given: 1\n");
      return 1;
    }

  /* A previous run of this function (possibly in another compiler run) made
     sure already that this file is up to date. Don't check it again to avoid
     an exponential number of preprocessor calls. */
  if (find_automake_tempfile_entry ("#up to date: ", gpi_filename, 1))
    {
      if (co->debug_automake)
        fprintf (stderr, "file marked as up to date: 0\n");
      return 0;
    }

  /* Check the name of the object file. If it doesn't exist, we must
     compile. If it is older than the GPI file, update the time. */
  stat (gpi_filename, &gpi_status);
  stat (source_name, &source_status);
  object_filename = locate_object_file (source_name);
  if (object_filename)
    {
      struct stat object_status;
      stat (object_filename, &object_status);
      if (gpi_status.st_mtime > object_status.st_mtime)
        gpi_status.st_mtime = object_status.st_mtime;
      free (object_filename);
    }
  else
    {
      if (co->debug_automake)
        fprintf (stderr, "no object filename: 1\n");
      return 1;
    }

  if (gpi_status.st_mtime < source_status.st_mtime)
    {
      if (co->debug_automake)
        fprintf (stderr, "source more recent than GPI or object file: 1\n");
      return 1;
    }

  /* GPI file older than imported GPI files => recompile. */
  for (interface = import_list; interface; interface = TREE_CHAIN (interface))
    {
      const char *p = IDENTIFIER_POINTER (INTERFACE_TABLE (interface)->interface_name);
      char *other_gpi_name = alloca (strlen (p) + 5), *q = other_gpi_name;
      if (p)
        while (*p)
          *q++ = TOLOWER (*p++);
      strcpy (q, ".gpi");
      q = locate_file (other_gpi_name, LF_COMPILED_UNIT);
      if (!q)
        {
          if (co->debug_automake)
            fprintf (stderr, "a needed GPI file does not exist: 1\n");
          return 1;
        }
      else
        {
          struct stat other_gpi_status;
          stat (q, &other_gpi_status);
          free (q);
          if (gpi_status.st_mtime < other_gpi_status.st_mtime)
            {
              if (co->debug_automake)
                fprintf (stderr, "a needed GPI file is more recent: 1\n");
              return 1;
            }
        }
    }

  /* Run the preprocessor with `-M' to create a dependency file.
     @@ Should do this when compiling the module and store the
     information in the GPI file. That would be faster. */
  dep_filename = choose_temp_base ();

  /* Touch dep_filename, so it won't be chosen as the name for another temp file */
  close (open (dep_filename, O_WRONLY | O_CREAT, 0666));

  /* Run the automake command. */
  gpc_args = concat (get_automake_switches (1),
                     "-M -o ", quote_arg (dep_filename),
                     " ", quote_arg (source_name), NULL);
  execute (automake_gpc ? automake_gpc : "gpc", gpc_args);
  free (gpc_args);

  /* Parse the `.d' file and check if the object file or the GPI file
     is older than one of the source files. If yes, recompile. */
  dep_file = fopen (dep_filename, "rt");
  if (!dep_file)
    {
      error ("cannot read dependency file `%s'", dep_filename);
      exit (FATAL_EXIT_CODE);
    }
  while (!feof (dep_file))
    if (fgets (dep_line, sizeof (dep_line), dep_file))
      {
        /* This is the name of a source file. If it is younger than the GPI file, recompile. */
        struct stat tmp_status;
        int l = strlen (dep_line);
        if (dep_line[l - 1] == '\n') dep_line[l - 1] = 0;
        stat (dep_line, &tmp_status);
        if (gpi_status.st_mtime < tmp_status.st_mtime)
          {
            fclose (dep_file);
            unlink (dep_filename);
            free (dep_filename);
            if (co->debug_automake)
              fprintf (stderr, "include file `%s' more recent: 1\n", dep_line);
            return 1;
          }
      }
  fclose (dep_file);
  unlink (dep_filename);
  free (dep_filename);

  add_to_automake_temp_file (ACONCAT (("#up to date: ", gpi_filename, NULL)));
  if (co->debug_automake)
    fprintf (stderr, "all checks passed: 0\n");
  return 0;
}

/* Compile a module during an automake.
   Return 0 on success, nonzero otherwise. */
int
compile_module (const char *filename, const char *destination_path)
{
  int result, pascal_source, cpp_source;
  char *plain_filename, *object_filename, *p, *fn, *gpc_args;
  const char *compiler_name;

  fn = locate_file (filename, LF_UNIT);
  /* File is being compiled => avoid a cycle.
     This also avoids compiling one source file twice with `--autobuild'. */
  /* @@@@@@ Kludge. Allow two simultaneous compilations of the same module
            (fjf40[57].pas), but not infinitely many (sven18[a-c].pas).
            The number 2 is arbitrary. */
  if (!fn || find_automake_tempfile_entry ("#compiling: ", fn, 2))
    {
      if (fn)
        free (fn);
      return -1;
    }

  /* Build the automake command line. */

  /* Pass automake GPC options only if Pascal source. */
  p = fn + strlen (fn) - 1;
  while (p > fn && *p != '.')
    p--;
  pascal_source = !strcmp (p, ".pas") || !strcmp (p, ".p")
                  || !strcmp (p, ".pp") || !strcmp (p, ".dpr");
  cpp_source = !strcmp (p, ".cc") || !strcmp (p, ".cpp") || !strcmp (p, ".C")
               || !strcmp (p, ".c++") || !strcmp (p, ".cxx");

  gpc_args = concat (get_automake_switches (pascal_source), "-c ", NULL);

  /* Create the object file in a special directory if one was specified. */
  if (destination_path)
    {
      /* p still points to the file name extension. */
      char *q = p;
      while (q >= fn && !IS_DIR_SEPARATOR (*q))
        q--;
      q++;
      if (p > q)
        {
          char tmp = *p;
          *p = 0;
          gpc_args = concat (gpc_args, "-o ", quote_arg (destination_path), quote_arg (q), ".o ", NULL);
          *p = tmp;
          if (pascal_source)
            gpc_args = concat (gpc_args, "--gpi-destination-path=", quote_arg (destination_path), " ", NULL);
        }
    }

  gpc_args = concat (gpc_args, quote_arg (fn), NULL);

  /* To compile C or C++ files, by default use the gpc compiler as read
     from the automake temp file (might be a cross-compiler, so using
     `gcc' or `g++' would be wrong). */
  compiler_name = automake_gpc ? automake_gpc : "gpc";
  if (cpp_source)
    compiler_name = automake_gpp ? automake_gpp : compiler_name;
  else if (!pascal_source)
    compiler_name = automake_gcc ? automake_gcc : compiler_name;

  /* Document what we are doing in the automake temp file. */
  add_to_automake_temp_file (ACONCAT (("#compiling: ", fn, NULL)));

  if (execute (compiler_name, gpc_args) == 1)
    result = 0;
  else
    result = -1;
  free (gpc_args);

  /* Tell the linker about the object file. */
  plain_filename = fn + strlen (fn) - 1;
  while (plain_filename > fn && !IS_DIR_SEPARATOR (*plain_filename))
    plain_filename--;
  if (IS_DIR_SEPARATOR (*plain_filename))
    plain_filename++;
  object_filename = xmalloc (strlen (plain_filename) + strlen (TARGET_OBJECT_SUFFIX) + 1);
  strcpy (object_filename, plain_filename);
  p = object_filename + strlen (plain_filename) - 1;
  while (p > object_filename && *p != '.')
    p--;
  *p = 0;
  strcat (object_filename, TARGET_OBJECT_SUFFIX);
  p = locate_file (object_filename, LF_COMPILED_UNIT);
  if (p)
    {
      add_to_link_file_list (p);
      free (p);
    }
  else if (!flag_syntax_only)
    error ("file `%s' not found", object_filename);

  free (fn);
  free (object_filename);

  return result;
}

/* GPI file handling -- storing and retrieving tree nodes in an
   implementation-dependent (but not *too* implementation-dependent ;-)
   "GNU Pascal Interface" binary file. For an introduction see internals.texi. */

/* In principle, wb and rb should be arguments to the various
   load/store routines. But they would have to be passed around
   unchanged to each recursive invocation which would be quite
   inefficient. But because they would be unchanged, and there are
   no other concurrent invocations of these routines, it's ok to
   make them static. */

static struct
{
  int size, count;
  tree storing_gpi_file;
  tree *nodes;
  gpi_int *offsets;
  char *main_exported;
  int *hashlist_next;
  int hash_table[MAX_HASH_TABLE];
  size_t outbufsize, outbufcount;
  unsigned char *outbuf;
} wb;

static struct
{
  gpi_int *offsets;
  tree *nodes;
  MEMFILE *infile;
} rb;

static inline void
store_length_f (FILE *f, const void *x, size_t l)
{
  size_t r = fwrite (x, l, 1, f);
  if (r != 1)
    {
      error ("fwrite result: %lu", (unsigned long int) r);
      perror ("fwrite");
      exit (FATAL_EXIT_CODE);
    }
}

#define STORE_ANY_F(F, X) store_length_f ((F), &(X), sizeof (X))
#define STORE_ANY(X) store_length (&(X), sizeof (X))

static void
store_length (const void *buf, size_t size)
{
  if (wb.outbufcount + size > wb.outbufsize)
    {
      while (wb.outbufcount + size > wb.outbufsize)
        wb.outbufsize *= 2;
      wb.outbuf = (unsigned char *) xrealloc (wb.outbuf, wb.outbufsize);
    }
  memcpy (wb.outbuf + wb.outbufcount, buf, size);
  wb.outbufcount += size;
}

#define LOAD_LENGTH_F mread1
#define LOAD_ANY_F(F, X) LOAD_LENGTH_F ((F), &(X), sizeof (X))
#define LOAD_LENGTH(X, L) LOAD_LENGTH_F (rb.infile, (X), (L))
#define LOAD_ANY(X) LOAD_LENGTH (&(X), sizeof (X))

static void
start_chunk (FILE *s, int code, gpi_int size)
{
  unsigned char c = code;
  STORE_ANY_F (s, c);
  STORE_ANY_F (s, size);
}

static void
store_string_chunk (FILE *s, int code, const char *str)
{
  gpi_int l = strlen (str);
  start_chunk (s, code, l);
  if (l > 0)
    store_length_f (s, str, l);
  if (co->debug_gpi)
    fprintf (stderr, "GPI storing %s: %s\n", gpi_chunk_names[code], *str ? str : "(empty)");
}

static inline void
store_string (const char *str)
{
  gpi_int l = strlen (str);
  STORE_ANY (l);
  if (l > 0)
    store_length (str, l);
}

int
is_gpi_special_node (tree node)
{
  unsigned int i;
  for (i = 0; i < NUM_SPECIAL_NODES; i++)
    if (*(special_nodes[i]) == node)
      return 1;
  return 0;
}

static tree
dequalify_id (tree id)
{
  const char *str = strchr (IDENTIFIER_POINTER (id), '.');
  gcc_assert (str);
  return get_identifier (str + 1);
}

static void
store_tree (tree name, FILE *s, tree main_node)
{
  int n, offset_size;
  gpi_int main_node_id, checksum;
  tree *tt;
  int autoexporting = 0;

  /* How many nodes will be stored (approx.; will be extended when necessary) */
  wb.size = list_length (main_node) + 1024 + NUM_SPECIAL_NODES;
  wb.nodes = (tree *) xmalloc (wb.size * sizeof (tree));
  wb.offsets = (gpi_int *) xmalloc (wb.size * sizeof (gpi_int));
  wb.main_exported = (char *) xmalloc (wb.size * sizeof (char));
  wb.hashlist_next = (int *) xmalloc (wb.size * sizeof (int));
  wb.outbuf = (unsigned char *) xmalloc ((wb.outbufsize = 1024));
  wb.outbufcount = 0;
  wb.storing_gpi_file = name;
  for (n = 0; n < MAX_HASH_TABLE; n++)
    wb.hash_table[n] = -1;

  /* If this ever fails, the type for storing tree codes in GPI files must be enlarged. */
  gcc_assert (LAST_AND_UNUSED_PASCAL_TREE_CODE < 255);

  /* Put the special nodes in the hash table.
     The reason for the backward loop is only that the "more common"
     nodes (e.g., integer_type_node vs. ptrdiff_type_node if they
     are the same) are processed last and therefore inserted at the
     front of the hash list and thus actually used in GPIs. */
  for (wb.count = NUM_SPECIAL_NODES - 1; wb.count >= 0; wb.count--)
    {
      tree special_node = *(special_nodes[wb.count]);
      int h = HASH_FUNC (special_node);
      wb.nodes[wb.count] = special_node;
      wb.offsets[wb.count] = -1;
      wb.main_exported[wb.count] = 0;
      wb.hashlist_next[wb.count] = wb.hash_table[h];
      wb.hash_table[h] = wb.count;
    }
  wb.count = n = NUM_SPECIAL_NODES;

  /* Put the elements of the main list into the nodes buffer. Remove duplicates
     the main list may contain (e.g., `export Foo = all (...)'). */
  get_node_id (TREE_VALUE (main_node));
  tt = &TREE_CHAIN (main_node);
  while (*tt)
    {
      int ignore = 0;
      tree id = TREE_VALUE (*tt), rename = TREE_PURPOSE (*tt);
      if (!id)
        {
          ignore = 1;
          if (rename == integer_zero_node)
            autoexporting = 1;
        }
      else if (TREE_CODE (id) == IMPORT_NODE)
        get_node_id (id);
      else
        {
          tree value = IDENTIFIER_VALUE (id);
          if (!value)
            {
              struct predef *p = IDENTIFIER_BUILT_IN_VALUE (id);
              if (p && (!co->pascal_dialect || (co->pascal_dialect & p->dialect)))
                error ("cannot export built-in `%s'", IDENTIFIER_NAME (id));
              else
                error ("exporting unknown identifier `%s'", IDENTIFIER_NAME (id));
              ignore = 1;
            }
          else if (rename)
            {
              int c2 = get_node_id (rename);
              if (wb.main_exported[c2] == 1)
                {
                  error ("duplicate exported identifier `%s' due to renaming", IDENTIFIER_NAME (rename));
                  ignore = 1;
                }
              else
                {
                  wb.main_exported[c2] = 1;
                  gcc_assert (!autoexporting);
                  TREE_VALUE (*tt) = rename;
                  if (TREE_CODE (value) == CONST_DECL && PASCAL_CST_PRINCIPAL_ID (value))
                    {
                      tree nd = build_decl (CONST_DECL, rename, TREE_TYPE (value));
                      DECL_INITIAL (nd) = DECL_INITIAL (value);
                      value = nd;
                    }
                }
            }
          else if (PASCAL_QUALIFIED_ID (id))
            TREE_VALUE (*tt) = id = dequalify_id (id);
          if (!ignore)
            {
              int c1 = get_node_id (id);
              get_node_id (value);
              TREE_PURPOSE (*tt) = value;
              if (wb.main_exported[c1] && autoexporting)
                ignore = 1;
              else if (!rename && wb.main_exported[c1] == 1)
                error ("duplicate exported identifier `%s'", IDENTIFIER_NAME (id));
              wb.main_exported[c1] = rename ? 2 : 1;
            }
        }
      if (ignore)
        *tt = TREE_CHAIN (*tt);
      else
        tt = &TREE_CHAIN (*tt);
    }

  /* Successively store all nodes from the tree buffer.
     Note that wb.count can grow during the loop. */
  while (wb.count > n)
    {
      wb.offsets[n] = wb.outbufcount;
      store_node_fields (wb.nodes[n], n);
      n++;
    }

  /* Store main node as the last node (this condition may actually be unnecessary) */
  main_node_id = get_node_id (main_node);
  wb.offsets[n] = wb.outbufcount;
  store_node_fields (wb.nodes[n], n);
  gcc_assert (wb.count == n + 1 && n == main_node_id);

  /* Just some statistics for those who want to check the quality of the hash function */
  if (co->debug_gpi)
    {
#define MAX_COLLISION_COUNT 1024
      int collision_count[MAX_COLLISION_COUNT], h, i;
      for (i = 0; i < MAX_COLLISION_COUNT; i++)
        collision_count[i] = 0;
      for (h = 0; h < MAX_HASH_TABLE; h++)
        {
          i = 0;
          for (n = wb.hash_table[h]; n >= 0; n = wb.hashlist_next[n])
            i++;
          if (i >= MAX_COLLISION_COUNT)
            i = MAX_COLLISION_COUNT - 1;
          collision_count[i]++;
        }
      fprintf (stderr, "GPI summary: Hash distribution:\nCollisions  Times\n");
      for (i = 1; i < MAX_COLLISION_COUNT; i++)
        if (collision_count[i] != 0)
          fprintf (stderr, "%10i%c %i\n", i - 1, i == MAX_COLLISION_COUNT - 1 ? '+' : ' ',
                   collision_count[i]);
    }

  /* Write chunk to file */
  checksum = compute_checksum (wb.outbuf, wb.outbufcount);
  itab_check_gpi_checksum (name, checksum, 1);
  start_chunk (s, GPI_CHUNK_NODES, wb.outbufcount + sizeof (checksum));
  store_length_f (s, wb.outbuf, wb.outbufcount);
  STORE_ANY_F (s, checksum);

  /* Write offset table, excluding the special nodes */
  offset_size = (wb.count - NUM_SPECIAL_NODES) * sizeof (gpi_int);
  start_chunk (s, GPI_CHUNK_OFFSETS, offset_size + sizeof (main_node_id));
  store_length_f (s, wb.offsets + NUM_SPECIAL_NODES, offset_size);
  STORE_ANY_F (s, main_node_id);

  wb.storing_gpi_file = NULL_TREE;
  free (wb.nodes);
  free (wb.offsets);
  free (wb.main_exported);
  free (wb.hashlist_next);
  free (wb.outbuf);
}

static int
get_node_id (tree node)
{
  int n, h = HASH_FUNC (node);
  for (n = wb.hash_table[h]; n >= 0; n = wb.hashlist_next[n])
    {
      gcc_assert (n < wb.count);
      if (wb.nodes[n] == node)
        break;
    }
  if (n < 0)
    {
      /* New node. Allocate new number and maintain the hash table */
      if (wb.count >= wb.size)
        {
          wb.size *= 2;
          wb.nodes = (tree *) xrealloc (wb.nodes, wb.size * sizeof (tree));
          wb.offsets = (gpi_int *) xrealloc (wb.offsets, wb.size * sizeof (gpi_int));
          wb.main_exported = (char *) xrealloc (wb.main_exported, wb.size * sizeof (char));
          wb.hashlist_next = (int *) xrealloc (wb.hashlist_next, wb.size * sizeof (int));
        }
      n = wb.count++;
      wb.nodes[n] = node;
      wb.main_exported[n] = 0;
      wb.hashlist_next[n] = wb.hash_table[h];
      wb.hash_table[h] = n;
    }
  return n;
}

/* Put node into hash table if not there already and write an index in the GPI file */
static void
store_node (tree node)
{
  gpi_int n = get_node_id (node);
  STORE_ANY (n);
}

static int loading_module_interface;

static tree
load_tree (MEMFILE *s, gpi_int start_of_nodes, gpi_int size_of_offsets, int module_interface)
{
  tree result;
  int n, nodes_count;
  size_of_offsets -= sizeof (gpi_int);  /* main node id */
  nodes_count = (size_of_offsets / sizeof (gpi_int)) + NUM_SPECIAL_NODES;

  /* Read offset table */
  rb.infile = s;
  rb.offsets = (gpi_int *) xmalloc (nodes_count * sizeof (gpi_int));
  LOAD_LENGTH (rb.offsets + NUM_SPECIAL_NODES, size_of_offsets);
  for (n = NUM_SPECIAL_NODES; n < nodes_count; n++)
    rb.offsets[n] += start_of_nodes;

  /* Predefine the standard nodes */
  rb.nodes = (tree *) xmalloc (nodes_count * sizeof (tree));
  memset (rb.nodes, 0, nodes_count * sizeof (tree));
  for (n = 0; n < (int) NUM_SPECIAL_NODES; n++)
    {
      rb.offsets[n] = -1;
      rb.nodes[n] = *(special_nodes[n]);
      if (n != 0 && !rb.nodes[n])
        {
          error ("internal compiler error: special node #%i is NULL", n);
          exit (FATAL_EXIT_CODE);
        }
    }

  /* Load and return the tree */
#ifndef EGCS97
  push_obstacks_nochange ();
  end_temporary_allocation ();
#endif
  loading_module_interface = module_interface ;
  result = load_node ();
  /* Do this here after all nodes have been loaded and are thus complete. */
  for (n = NUM_SPECIAL_NODES; n < nodes_count; n++)
    {
      tree t = rb.nodes[n];
      if (t && (TREE_CODE (t) == FUNCTION_DECL || (TREE_CODE (t) == VAR_DECL))
#ifndef GCC_4_0 
          && !DECL_RTL_SET_P (t)
#else
          && !PASCAL_DECL_IMPORTED (t)
#endif
          )
        {
          if (!module_interface)
            {
              if (TREE_CODE (t) == FUNCTION_DECL)
                PASCAL_FORWARD_DECLARATION (t) = 0;
              else
                DECL_EXTERNAL (t) = 1;  /* not for module interface so init_any won't ignore it */
#if 0
              if (TREE_CODE (t) == VAR_DECL)
                DECL_INITIAL (t) = NULL_TREE;
#endif
            }
#ifdef GCC_4_0
          else
            {
              if (TREE_CODE (t) == VAR_DECL)
                rest_of_decl_compilation (t, 1, 0);
            }
#endif
          PASCAL_DECL_WEAK (t) = 0;
          PASCAL_DECL_IMPORTED (t) = 1;
#ifndef GCC_4_0
          rest_of_decl_compilation (t, NULL, 1, 1);
#endif
        }
      /* Support `private' for object fields/methods */
      if (!module_interface
          && t && (TREE_CODE (t) == FIELD_DECL || TREE_CODE (t) == FUNCTION_DECL) && TREE_PRIVATE (t))
        TREE_PROTECTED (t) = 1;
    }
#ifndef EGCS97
  pop_obstacks ();
#endif
  free (rb.offsets);
  free (rb.nodes);
  return result;
}

static void
itab_store_node (struct interface_table_t *itab, gpi_int uid, tree t)
{
  if (uid >= itab->count)
    {
      gpi_int n, old_count = itab->count;
      while (itab->count <= uid) itab->count *= 2;  /* avoid too many reallocations */
#ifndef GCC_3_3
      itab->nodes = (tree *) xrealloc (itab->nodes, itab->count * sizeof (tree));
      itab->hashlist_next = (int *) xrealloc (itab->hashlist_next, itab->count * sizeof (int));
#else
      itab->nodes = (tree *) ggc_realloc (itab->nodes, itab->count * sizeof (tree));
      itab->hashlist_next = (int *) ggc_realloc (itab->hashlist_next, itab->count * sizeof (int));
#endif
      for (n = old_count; n < itab->count; n++)
        {
          itab->nodes[n] = NULL_TREE;
          itab->hashlist_next[n] = -1;
        }
    }

  /* When storing, the node may have been loaded already indirectly
     via another interface in the case of cyclic dependencides. */
  if (!itab->nodes[uid])
    {
      int hash = HASH_FUNC (t);
      itab->nodes[uid] = t;
      itab->hashlist_next[uid] = itab->hash_table[hash];
      itab->hash_table[hash] = uid;
    }
}

/* Load a string out of a memfile */
static char *
load_string (MEMFILE *s)
{
  char *str;
  gpi_int l;
  LOAD_ANY_F (s, l);
  str = (char *) xmalloc ((int) l + 1);
  if (l > 0)
    LOAD_LENGTH_F (s, str, l);
  str[l] = 0;
  return str;
}

/* Storing/loading a node's flags. @@@@ Very much GCC version dependent. */
#ifdef EGCS97
#ifdef GCC_4_0
#define DECL_FLAGS_SIZE 8
#else
#define DECL_FLAGS_SIZE 6
#endif
#ifndef GCC_4_1
#define DECL_EXTRA_STORED(t) (t->decl.u1.i)
#else
#define DECL_EXTRA_STORED(t) (t->decl_common.u1.i)
#endif
#else
#ifdef EGCS
#define DECL_FLAGS_SIZE 5
#else
#define DECL_FLAGS_SIZE 4
#endif
#define DECL_EXTRA_STORED(t) DECL_FRAME_SIZE (t)
#endif

#ifndef GCC_4_0
#define FLAGS_OFFSET (2*sizeof(tree *))
#else
#ifndef GCC_4_3
#define FLAGS_OFFSET (3*sizeof(tree *))
#else
#define FLAGS_OFFSET 2
#endif
#endif

#ifndef GCC_4_3
#define FLAGS_SIZE 4
#else
#define FLAGS_SIZE 6
#endif

static void
store_flags (tree t)
{
  int save = TREE_ASM_WRITTEN (t);
  /* Reset TREE_ASM_WRITTEN in the GPI file for types
     where it refers to debug info (see ../tree.h). */
  if (TYPE_P (t))
    TREE_ASM_WRITTEN (t) = 0;
  store_length ((char *) t + FLAGS_OFFSET, FLAGS_SIZE);
  TREE_ASM_WRITTEN (t) = save;
}
#define load_flags(t) LOAD_LENGTH ((char *) t + FLAGS_OFFSET, FLAGS_SIZE)

/* Store the fields of a node in a stream. */
static void
store_node_fields (tree t, int uid)
{
  unsigned char code;
  int class_done = 0;

#ifdef USE_GPI_DEBUG_KEY
  const gpi_int debug_key = GPI_DEBUG_KEY;
  STORE_ANY (debug_key);
#endif

  /* UID hashing does not work for IDENTIFIER_NODEs because their
     fields can change between interfaces. */
  if (TREE_CODE (t) == INTERFACE_NAME_NODE || TREE_CODE (t) == IDENTIFIER_NODE)
    store_node (NULL_TREE);
  else
    {
      struct interface_table_t *itab;
      int hash = HASH_FUNC (t);
      gpi_int n = -1;
      for (itab = interface_table; itab; itab = itab->next)
        {
          for (n = itab->hash_table[hash]; n >= 0; n = itab->hashlist_next[n])
            {
              gcc_assert (n < itab->count);
              if (itab->nodes[n] == t)
                break;
            }
          if (n >= 0)
            break;
        }
      if (itab)
        {
          gcc_assert (itab->interface_name_node);
          store_node (itab->interface_name_node);
          STORE_ANY (n);
        }
      else
        {
          store_node (NULL_TREE);
          itab_store_node (get_interface_table (wb.storing_gpi_file, current_module->name), uid, t);
        }
    }

  code = (unsigned char) TREE_CODE (t);
  STORE_ANY (code);
  if (co->debug_gpi)
    {
      fprintf (stderr, "GPI storing <%i>:\n", uid);
      if (code == INTERFACE_NAME_NODE)
        {
          fprintf (stderr, " <interface_name_node ");
          fprintf (stderr, GPC_HOST_PTR_PRINTF, (HOST_PTR_PRINTF_CAST_TYPE) t);
          fprintf (stderr, " %s module %s checksum %lu>\n",
                   IDENTIFIER_NAME (INTERFACE_TABLE (t)->interface_name),
                   IDENTIFIER_NAME (INTERFACE_TABLE (t)->module_name),
                   (unsigned long int) INTERFACE_TABLE (t)->gpi_checksum);
        }
      else
        /* debug_tree (t); */
        fprintf(stderr, "<%s>\n", tree_code_name[code]);
    }
  if (code != IDENTIFIER_NODE && code != INTERFACE_NAME_NODE && code != TREE_LIST)
    store_flags (t);
  switch (TREE_CODE_CLASS (code))
  {
    case tcc_type:
      store_length (&TYPE_UID (t) + 1, 4 + sizeof (TYPE_ALIGN (t)));
      store_node (TYPE_NAME (t));
      store_node (TYPE_SIZE (t));
#ifdef EGCS
      store_node (TYPE_SIZE_UNIT (t));
#endif
      store_node (TYPE_POINTER_TO (t));
      store_node (TYPE_GET_INITIALIZER (t));
      store_node (TYPE_MAIN_VARIANT (t) == t ? NULL_TREE : TYPE_MAIN_VARIANT (t));
      break;
    case tcc_declaration:
      {
        gpi_int n;
        store_length ((&DECL_SIZE (t)) + 1, DECL_FLAGS_SIZE);
#ifndef GCC_4_2
        STORE_ANY (DECL_EXTRA_STORED (t));
#endif
#ifdef  GCC_4_1
        if (CODE_CONTAINS_STRUCT (code, TS_DECL_MINIMAL))
#endif
          store_node (DECL_NAME (t));
        store_string (DECL_SOURCE_FILE (t));
        n = DECL_SOURCE_LINE (t);
        STORE_ANY (n);
        n = /* @@ DECL_SOURCE_COLUMN (t) */ 0;
        STORE_ANY (n);
        store_node (DECL_SIZE (t));
#ifdef EGCS97
        store_node (DECL_SIZE_UNIT (t));
#endif
#ifdef GCC_4_1
        if (code != FUNCTION_DECL)
#endif
          {
            n = DECL_ALIGN (t);
            STORE_ANY (n);
          }
        break;
      }
    case tcc_constant:
      store_node (TREE_TYPE (t));
      break;
    case tcc_unary:
    case tcc_binary:
#ifndef GCC_4_0
    case '3':
#endif
    case tcc_comparison:
    case tcc_expression:
    case tcc_reference:
      {
        int i, l = NUMBER_OF_OPERANDS (code);
        store_node (TREE_TYPE (t));
        for (i = FIRST_OPERAND (code); i < l; i++)
          store_node (TREE_OPERAND (t, i));
        class_done = 1;
        break;
      }
    default:
      break;
  }
  switch (code)
  {
    case INTERFACE_NAME_NODE:
      gcc_assert (INTERFACE_TABLE (t)->interface_name && INTERFACE_TABLE (t)->module_name);
      store_string (IDENTIFIER_POINTER (INTERFACE_TABLE (t)->interface_name));
      store_string (IDENTIFIER_POINTER (INTERFACE_TABLE (t)->module_name));
      STORE_ANY (INTERFACE_TABLE (t)->gpi_checksum);
      break;

    case IDENTIFIER_NODE:
      store_string (IDENTIFIER_POINTER (t));
      if (IDENTIFIER_SPELLING (t))
        {
          gpi_int l = IDENTIFIER_SPELLING_LINENO (t), c = IDENTIFIER_SPELLING_COLUMN (t);
          store_string (IDENTIFIER_SPELLING (t));
          store_string (IDENTIFIER_SPELLING_FILE (t) ? IDENTIFIER_SPELLING_FILE (t) : "");
          STORE_ANY (l);
          STORE_ANY (c);
        }
      else
        store_string ("");
      break;

    case IMPORT_NODE:
      {
        gpi_int q = PASCAL_TREE_QUALIFIED (t);
        store_node (IMPORT_INTERFACE (t));
        store_node (IMPORT_QUALIFIER (t));
        store_node (IMPORT_FILENAME (t));
        STORE_ANY (q);
        break;
      }

    case TREE_LIST:
      {
        tree t0;
        gpi_int n = list_length (t);
        STORE_ANY (n);
        for (t0 = t; t0; t0 = TREE_CHAIN (t0))
          {
            store_flags (t0);
            store_node (TREE_PURPOSE (t0));
            store_node (TREE_VALUE (t0));
          }
        break;
      }

    case VOID_TYPE:
      store_node (TREE_TYPE (t));
      break;

    case REAL_TYPE:
    case COMPLEX_TYPE:
    case BOOLEAN_TYPE:
#ifndef GCC_4_2
    case CHAR_TYPE:
#endif
    case INTEGER_TYPE:
    case ENUMERAL_TYPE:
      store_node (TREE_TYPE (t));
      store_node (TYPE_MIN_VALUE (t));
      store_node (TYPE_MAX_VALUE (t));
      if (code == ENUMERAL_TYPE)
        store_node (TYPE_VALUES (t));
      break;

    case SET_TYPE:
      store_node (TREE_TYPE (t));
      store_node (TYPE_DOMAIN (t));
      break;

    case POINTER_TYPE:
    case REFERENCE_TYPE:
      store_node (TREE_TYPE (t));
      break;

    case ARRAY_TYPE:
      store_node (TREE_TYPE (t));
      store_node (TYPE_DOMAIN (t));
      break;

    case RECORD_TYPE:
    case UNION_TYPE:
    case QUAL_UNION_TYPE:
      {
        tree f;
        signed char lang_code;
        allocate_type_lang_specific (t);
        lang_code = TYPE_LANG_CODE (t);
        STORE_ANY (lang_code);
        if (PASCAL_TYPE_FILE (t))
          store_node (TREE_TYPE (t));
        store_node (TYPE_LANG_INFO (t));
        store_node (TYPE_LANG_BASE (t));
        /* Sanity check */
        gcc_assert (!TYPE_LANG_INFO (t)
                    || lang_code == PASCAL_LANG_NON_TEXT_FILE
                    || lang_code == PASCAL_LANG_TEXT_FILE
                    || lang_code == PASCAL_LANG_VARIANT_RECORD
                    || lang_code == PASCAL_LANG_OBJECT
                    || lang_code == PASCAL_LANG_ABSTRACT_OBJECT
                    || lang_code == PASCAL_LANG_UNDISCRIMINATED_STRING
                    || lang_code == PASCAL_LANG_PREDISCRIMINATED_STRING
                    || lang_code == PASCAL_LANG_DISCRIMINATED_STRING
                    || lang_code == PASCAL_LANG_FAKE_ARRAY);
        for (f = TYPE_FIELDS (t); f; f = TREE_CHAIN (f))
          {
            HOST_WIDE_INT n;
            store_node (f);
#ifndef EGCS97
            store_node (bit_position (f));
#else
            store_node (DECL_FIELD_BIT_OFFSET (f));
            store_node (DECL_FIELD_OFFSET (f));
#endif
          }
        store_node (NULL_TREE);  /* end of field decls */
        if (PASCAL_TYPE_OBJECT (t))
          {
            for (f = TYPE_METHODS (t); f; f = TREE_CHAIN (f))
              store_node (f);
            store_node (NULL_TREE);  /* end of methods */
            store_node (TYPE_LANG_VMT_VAR (t));
          }
        break;
      }

    case FUNCTION_TYPE:
      {
        tree a;
        store_node (TREE_TYPE (t));
        store_node (TYPE_ARG_TYPES (t));
        for (a = TYPE_ATTRIBUTES (t); a; a = TREE_CHAIN (a))
          {
            store_node (TREE_VALUE (a));
            store_node (TREE_PURPOSE (a));
          }
        store_node (error_mark_node);
        break;
      }

    case INTEGER_CST:
      STORE_ANY (TREE_INT_CST_LOW (t));
      STORE_ANY (TREE_INT_CST_HIGH (t));
      break;

    case REAL_CST:
      STORE_ANY (TREE_REAL_CST (t));
      break;

    case COMPLEX_CST:
      store_node (TREE_REALPART (t));
      store_node (TREE_IMAGPART (t));
      break;

    case STRING_CST:
      {
        gpi_int l = TREE_STRING_LENGTH (t);
        STORE_ANY (l);
        store_length (TREE_STRING_POINTER (t), l);
        break;
      }

    case FUNCTION_DECL:
      {
        tree a;
        store_node (TREE_TYPE (t));
        store_string (IDENTIFIER_POINTER (DECL_ASSEMBLER_NAME (t)));
        allocate_decl_lang_specific (t);
        store_node (DECL_LANG_RESULT_VARIABLE (t));
        for (a = DECL_LANG_PARMS (t); a; a = TREE_CHAIN (a))
          store_node (a);
        store_node (NULL_TREE);
        store_node (DECL_CONTEXT (t));
        store_node (DECL_LANG_INFO3 (t));
        break;
      }

    case PARM_DECL:
      store_node (TREE_TYPE (t));
      store_node (DECL_ARG_TYPE (t));
      store_node (DECL_CONTEXT (t));
      break;

    case FIELD_DECL:
      {
        tree f;
        HOST_WIDE_INT n;
        /* Necessary under DJGPP when compiling a program that uses
           a unit first without, then with `-g' (e.g. fjf684.pas). */
        store_string (DECL_ASSEMBLER_NAME_SET_P (t) ? IDENTIFIER_POINTER (DECL_ASSEMBLER_NAME (t)) : "");
        store_node (TREE_TYPE (t));
#ifndef EGCS97
        store_node (bit_position (t));
#else
        store_node (DECL_FIELD_BIT_OFFSET (t));
        store_node (DECL_FIELD_OFFSET (t));
        n = DECL_OFFSET_ALIGN (t);
        STORE_ANY (n);
#endif
        store_node (DECL_BIT_FIELD_TYPE (t));
        f = DECL_LANG_SPECIFIC (t) ? DECL_LANG_FIXUPLIST (t) : NULL_TREE;
        store_node (f);
        break;
      }

    case CONST_DECL:
      store_node (TREE_TYPE (t));
      store_node (DECL_INITIAL (t));
      break;

    case LABEL_DECL:
    case RESULT_DECL:
    case TYPE_DECL:
      store_node (TREE_TYPE (t));
      break;

    case VAR_DECL:
      store_node (TREE_TYPE (t));
#if 1
      /* We need to store DECL_INITIAL to pass initial value from
         interface to the implementation */
      store_node (DECL_INITIAL (t));
#endif
      store_string (IDENTIFIER_POINTER (DECL_ASSEMBLER_NAME (t)));
      break;

    case OPERATOR_DECL:
    case NAMESPACE_DECL:
      break;

    case PLACEHOLDER_EXPR:
      store_node (TREE_TYPE (t));
      break;

#ifdef GCC_4_1
    case CONSTRUCTOR:
      {
        VEC(constructor_elt,gc) *elts = CONSTRUCTOR_ELTS (t);
        tree index, value;
        unsigned HOST_WIDE_INT ix;
        store_node (TREE_TYPE (t));
        ix = VEC_length (constructor_elt, elts);
        /* fprintf(stderr, "constructor with %ld elements\n", ix); */
        STORE_ANY (ix);
        FOR_EACH_CONSTRUCTOR_ELT (elts, ix, index, value)
          {
            store_node (index);
            store_node (value);
          }
      }
      break;
#endif
      
    default:
#ifdef GCC_4_0
      gcc_assert (class_done);
#else
      gcc_assert (class_done && code != RTL_EXPR);
#endif
  }
}

/* Return an interface table (newly allocated if not existing yet). */
static struct interface_table_t *
get_interface_table (tree interface_name, tree module_name)
{
  struct interface_table_t *itab;
  for (itab = interface_table; itab; itab = itab->next)
    if (itab->interface_name == interface_name)
      break;
  if (!itab)
    {
      gpi_int n;
#ifndef GCC_3_3
      itab = (struct interface_table_t *) xmalloc (sizeof (struct interface_table_t));
#else
      itab = (struct interface_table_t *) ggc_alloc (sizeof (struct interface_table_t));
#endif
      memset ((PTR) itab, 0, sizeof (struct interface_table_t));
      itab->count = 64;
#ifndef GCC_3_3
      itab->nodes = (tree *) xmalloc (itab->count * sizeof (tree));
      itab->hashlist_next = (int *) xmalloc (itab->count * sizeof (int));
#else
      itab->nodes = (tree *) ggc_alloc (itab->count * sizeof (tree));
      itab->hashlist_next = (int *) ggc_alloc (itab->count * sizeof (int));
#endif
      for (n = 0; n < itab->count; n++)
        {
          itab->nodes[n] = NULL_TREE;
          itab->hashlist_next[n] = -1;
        }
      itab->interface_name = interface_name;
      itab->module_name = module_name;
      itab->gpi_checksum = 0;
      itab->interface_name_node = NULL_TREE;
      itab->initializers = NULL_TREE;
#if defined (EGCS97) && !defined (GCC_3_3)
      ggc_add_tree_root (&(itab->interface_name), 1);
      ggc_add_tree_root (&(itab->module_name), 1);
      ggc_add_tree_root (&(itab->interface_name_node), 1);
      ggc_add_tree_root (&(itab->initializers), 1);
#endif
      for (n = 0; n < MAX_HASH_TABLE; n++)
        itab->hash_table[n] = -1;
      itab->next = interface_table;
      interface_table = itab;
    }
  else if (!itab->module_name)
    itab->module_name = module_name;
  else if (module_name && module_name != itab->module_name)
    {
      error ("interface `%s' in both modules `%s' and `%s'",
             IDENTIFIER_NAME (interface_name),
             IDENTIFIER_NAME (itab->module_name),
             IDENTIFIER_NAME (module_name));
      exit (FATAL_EXIT_CODE);
    }
  return itab;
}

/* Compute a checksum for a GPI file.
   @@ Simple weighted sum. Perhaps we should use MD5 or something. */
static gpi_int
compute_checksum (unsigned char *buf, gpi_int size)
{
  gpi_int sum = 0, n;
  for (n = 0; n < size; n++)
    sum += n * buf[n];
  return sum;
}

/* If update_flag is 0, the function checks if the checksum matches
   the one already stored (if any), returns 1 if so, 0 otherwise,
   but never sets it. If update_flag is 1, it fails fatally on a mismatch,
   otherwise always returns 1 and sets it if it wasn't stored before. */
static int
itab_check_gpi_checksum (tree interface_name, gpi_int gpi_checksum, int update_flag)
{
  struct interface_table_t *itab;
  tree t;
  for (itab = interface_table; itab; itab = itab->next)
    if (itab->interface_name == interface_name)
      break;
  gcc_assert (itab);
  if (itab->interface_name_node)
    {
      if (itab->gpi_checksum == gpi_checksum)
        return 1;
      if (update_flag)
        {
          error ("checksum mismatch for interface `%s' (recompile interfaces in the right order)",
                 IDENTIFIER_NAME (interface_name));
          exit (FATAL_EXIT_CODE);
        }
      return 0;
    }
  if (!update_flag)
    return 1;
  itab->gpi_checksum = gpi_checksum;
  t = make_node (INTERFACE_NAME_NODE);
  INTERFACE_TABLE (t) = itab;
  itab->interface_name_node = t;
  return 1;
}

/* Return the name of the module the interface named NAME is in. */
tree
itab_get_initializers (tree name)
{
  struct interface_table_t *itab;
  for (itab = interface_table; itab; itab = itab->next)
    if (itab->interface_name == name)
      break;
  gcc_assert (itab);
  return itab->initializers;
}

/* Load (parts of) a tree out of a stream.
   (A generalized version of this should go into tree.c.)
   Note: This function should not call any non-basic backend routines (i.e.,
   only make_node, get_identifier, build_tree_list etc.) because the nodes
   it deals with may be incomplete until the end and confuse the backend. */
static tree
load_node (void)
{
  gpi_int uid, original_uid, count;
  unsigned char code;
  size_t save_pos;
  struct interface_table_t *itab;
  tree interface_node, t = NULL_TREE;

  /* Check whether the node number n has already been loaded
     (this includes the special nodes). */
  LOAD_ANY (uid);
  /* fprintf(stderr, "uid = %ld, ", uid); */
  if (uid == 0 || rb.nodes[uid])
    {
      /* fprintf(stderr, "done "); */
      return rb.nodes[uid];
    }
  
  /* If not, seek file for reading the node */
  save_pos = mtell (rb.infile);
  mseek (rb.infile, rb.offsets[uid]);
#ifdef USE_GPI_DEBUG_KEY
  {
    gpi_int key;
    LOAD_ANY (key);
    gcc_assert (key == GPI_DEBUG_KEY);
  }
#endif

  interface_node = load_node ();
  if (interface_node)
    {
      LOAD_ANY (original_uid);
      itab = INTERFACE_TABLE (interface_node);
    }
  else
    {
      original_uid = uid;
      itab = current_interface_table;
    }
  if (original_uid < itab->count && itab->nodes[original_uid])
    {
      t = itab->nodes[original_uid];
      gcc_assert (t && !rb.nodes[uid]);
      rb.nodes[uid] = t;
      mseek (rb.infile, save_pos);
      return t;
    }

  LOAD_ANY (code);
  if (code == TREE_LIST)
    LOAD_ANY (count);
  if (code == IDENTIFIER_NODE)
    {
      char *id = load_string (rb.infile);
      t = get_identifier (id);
      free (id);
    }
  else if (code == STRING_CST)
    {
        char *s;
        struct {char c[FLAGS_SIZE];} pp;
        gpi_int l;
        tree ty;
        LOAD_ANY(pp);
        ty = load_node ();
        LOAD_ANY(l);
        s = xmalloc (l + 1);
        LOAD_LENGTH (s, l);
        t = build_string (l, s);
        memcpy (((char *) t) + FLAGS_OFFSET, &pp, FLAGS_SIZE);
        TREE_TYPE (t) = ty;
        free (s);
    }
  else
    t = make_node (code);
  itab_store_node (itab, original_uid, t);
  gcc_assert (!rb.nodes[uid]);
  rb.nodes[uid] = t;
  if (code != IDENTIFIER_NODE && code != INTERFACE_NAME_NODE
      && code != STRING_CST)
    load_flags (t);
#if 0
  if (co->debug_gpi)
    {
      fprintf (stderr, "GPI loading <%i>: ", (int) uid);
      /* debug_tree (t); */
      fprintf (stderr, "<%s>\n", tree_code_name[code]);
    }
#endif

  switch (TREE_CODE_CLASS (code))
  {
    case tcc_type:
      {
        tree tmp;
        LOAD_LENGTH (&TYPE_UID (t) + 1, 4 + sizeof (TYPE_ALIGN (t)));
        TYPE_NAME (t) = load_node ();
        TYPE_SIZE (t) = load_node ();
#ifdef EGCS
        TYPE_SIZE_UNIT (t) = load_node ();
#endif
        TYPE_POINTER_TO (t) = load_node ();
#ifdef GCC_4_0
        TYPE_CACHED_VALUES_P (t) = 0;
        TYPE_CACHED_VALUES (t) = NULL_TREE;
#endif
        tmp = load_node ();
        if (tmp)
          {
            allocate_type_lang_specific (t);
            TYPE_LANG_INITIAL (t) = tmp;
          }
        tmp = load_node ();
        if (tmp)
          {
            tmp = TYPE_MAIN_VARIANT (tmp);
            TYPE_MAIN_VARIANT (t) = tmp;
            TYPE_NEXT_VARIANT (t) = TYPE_NEXT_VARIANT (tmp);
            TYPE_NEXT_VARIANT (tmp) = t;
          }
        break;
      }
    case tcc_declaration:
      {
        gpi_int n;
        char *s;
        LOAD_LENGTH ((&DECL_SIZE (t)) + 1, DECL_FLAGS_SIZE);
#ifndef GCC_4_2
        LOAD_ANY (DECL_EXTRA_STORED (t));
#endif
#ifdef  GCC_4_1
        if (CODE_CONTAINS_STRUCT (code, TS_DECL_MINIMAL))
#endif
          DECL_NAME (t) = load_node ();
        s = load_string (rb.infile);
        LOAD_ANY (n);
#ifndef GCC_3_4
        DECL_SOURCE_FILE (t) = PERMANENT_STRING (s);
        DECL_SOURCE_LINE (t) = n;
#else
        DECL_SOURCE_LOCATION (t) =
           pascal_make_location(PERMANENT_STRING (s), n);
#endif
        free (s);
        LOAD_ANY (n);
        /* @@ DECL_SOURCE_COLUMN (t) = n; */
        DECL_SIZE (t) = load_node ();
#ifdef EGCS97
        DECL_SIZE_UNIT (t) = load_node ();
#endif
#ifdef GCC_4_1
        if (code != FUNCTION_DECL)
#endif
          {
            LOAD_ANY (n);
            DECL_ALIGN (t) = n;
          }
#ifdef GCC_4_1
        if (CODE_CONTAINS_STRUCT (code, TS_DECL_WITH_VIS))
#endif
          DECL_IN_SYSTEM_HEADER (t) = 1;
        break;
      }
    case tcc_constant:
      if (code != STRING_CST)
        TREE_TYPE (t) = load_node ();
      break;
    case tcc_unary:
    case tcc_binary:
#ifndef GCC_4_0
    case '3':
#endif
    case tcc_comparison:
    case tcc_expression:
    case tcc_reference:
      {
        int i, l = NUMBER_OF_OPERANDS (code);
        TREE_TYPE (t) = load_node ();
        for (i = FIRST_OPERAND (code); i < l; i++)
          TREE_OPERAND (t, i) = load_node ();
        break;
      }
    default:
      break;
  }
  switch (code)
  {
    case INTERFACE_NAME_NODE:
      {
        gpi_int gpi_checksum;
        tree i, m;
        char *id;
        id = load_string (rb.infile);
        i = get_identifier (id);
        free (id);
        id = load_string (rb.infile);
        m = get_identifier (id);
        free (id);
        LOAD_ANY (gpi_checksum);
        INTERFACE_TABLE (t) = get_interface_table (i, m);
        itab_check_gpi_checksum (i, gpi_checksum, 1);
        mseek (rb.infile, save_pos);
        if (co->debug_gpi)
          {
            fprintf (stderr, "GPI loaded <%i>:\n <interface_name_node ", (int) uid);
            fprintf (stderr, GPC_HOST_PTR_PRINTF, (HOST_PTR_PRINTF_CAST_TYPE) t);
            fprintf (stderr, " %s module %s checksum %lu>\n",
                     IDENTIFIER_NAME (i),
                     IDENTIFIER_NAME (m),
                     (unsigned long int) gpi_checksum);
          }
        return t;
      }

    case IDENTIFIER_NODE:
      {
        gpi_int line, column;
        char *filename, *spelling = load_string (rb.infile);
        if (*spelling)
          {
            filename = load_string (rb.infile);
            LOAD_ANY (line);
            LOAD_ANY (column);
            set_identifier_spelling (t, spelling, (*filename && co->warn_id_case > 1) ? filename : NULL, line, column);
          }
        free (spelling);
        break;
      }

    case IMPORT_NODE:
      {
        gpi_int q;
        IMPORT_INTERFACE (t) = load_node ();
        IMPORT_QUALIFIER (t) = load_node ();
        IMPORT_FILENAME (t) = load_node ();
        LOAD_ANY (q);
        PASCAL_TREE_QUALIFIED (t) = q;
        break;
      }

    case TREE_LIST:
      {
        tree last = t;
        while (1)
          {
            TREE_PURPOSE (last) = load_node ();
            TREE_VALUE (last) = load_node ();
            if (!--count)
              break;
            TREE_CHAIN (last) = make_node (TREE_LIST);
            last = TREE_CHAIN (last);
            load_flags (last);
          }
        break;
      }

    case VOID_TYPE:
      TREE_TYPE (t) = load_node ();
      break;

    case REAL_TYPE:
    case COMPLEX_TYPE:
    case BOOLEAN_TYPE:
#ifndef GCC_4_2
    case CHAR_TYPE:
#endif
    case INTEGER_TYPE:
    case ENUMERAL_TYPE:
      TREE_TYPE (t) = load_node ();
      TYPE_MIN_VALUE (t) = load_node ();
      TYPE_MAX_VALUE (t) = load_node ();
      if (code == ENUMERAL_TYPE)
        {
          TYPE_VALUES (t) = load_node ();
          TYPE_STUB_DECL (t) = build_decl (TYPE_DECL, NULL_TREE, t);
        }
      break;

    case SET_TYPE:
      TREE_TYPE (t) = load_node ();
      TYPE_DOMAIN (t) = load_node ();
      break;

    case POINTER_TYPE:
    case REFERENCE_TYPE:
      TREE_TYPE (t) = load_node ();
      break;

    case ARRAY_TYPE:
      TREE_TYPE (t) = load_node ();
      TYPE_DOMAIN (t) = load_node ();
      break;

    case RECORD_TYPE:
    case UNION_TYPE:
    case QUAL_UNION_TYPE:
      {
        tree *p;
        signed char lang_code;
        allocate_type_lang_specific (t);
        LOAD_ANY (lang_code);
        TYPE_LANG_CODE (t) = lang_code;
        if (PASCAL_TYPE_FILE (t))
          TREE_TYPE (t) = load_node ();
        TYPE_LANG_INFO (t) = load_node ();
        TYPE_LANG_BASE (t) = load_node ();
        p = &TYPE_FIELDS (t);
        while ((*p = load_node ()))
          {
            DECL_CONTEXT (*p) = t;
#ifndef EGCS97
            bit_position (*p) = load_node ();
#else
            DECL_FIELD_BIT_OFFSET (*p) = load_node ();
            DECL_FIELD_OFFSET (*p) = load_node ();
#endif
            p = &TREE_CHAIN (*p);
          }

        if (PASCAL_TYPE_OBJECT (t))
          {
            /* Load methods */
            p = &TYPE_METHODS (t);
            while ((*p = load_node ()))
              p = &TREE_CHAIN (*p);
            TYPE_LANG_VMT_VAR (t) = load_node ();
          }
        TYPE_STUB_DECL (t) = build_decl (TYPE_DECL, NULL_TREE, t);
        sort_fields (t);  /* Since the array depends on the ordering of
                             pointers, we must not store it in GPI files */
        break;
      }

    case FUNCTION_TYPE:
      {
        tree a;
        TREE_TYPE (t) = load_node ();
        TYPE_ARG_TYPES (t) = load_node ();
        while ((a = load_node ()) != error_mark_node)
          TYPE_ATTRIBUTES (t) = chainon (TYPE_ATTRIBUTES (t), build_tree_list (load_node (), a));
        break;
      }

    case INTEGER_CST:
      LOAD_ANY (TREE_INT_CST_LOW (t));
      LOAD_ANY (TREE_INT_CST_HIGH (t));
      break;

    case REAL_CST:
#ifndef GCC_3_3
      LOAD_ANY (TREE_REAL_CST (t));
#else
      {
        REAL_VALUE_TYPE *dp = ggc_alloc (sizeof (REAL_VALUE_TYPE));
        LOAD_ANY (*dp);
        TREE_REAL_CST_PTR (t) = dp;
      }
#endif
      break;

    case COMPLEX_CST:
      TREE_REALPART (t) = load_node ();
      TREE_IMAGPART (t) = load_node ();
      break;

    case FUNCTION_DECL:
      {
        char *assembler_name_str;
        tree *last_arg;
        allocate_decl_lang_specific (t);
        TREE_TYPE (t) = load_node ();
        DECL_EXTERNAL (t) = 1;
        assembler_name_str = load_string (rb.infile);
        gcc_assert (*assembler_name_str);
        SET_DECL_ASSEMBLER_NAME (t, get_identifier (assembler_name_str));
        free (assembler_name_str);
        DECL_LANG_RESULT_VARIABLE (t) = load_node ();
        last_arg = &DECL_LANG_PARMS (t);
        while ((*last_arg = load_node ()))
          last_arg = &TREE_CHAIN (*last_arg);
        DECL_CONTEXT (t) = load_node ();
        DECL_LANG_INFO3 (t) = load_node ();
        pascal_decl_attributes (&t, TYPE_ATTRIBUTES (TREE_TYPE (t)));
        break;
      }

    case PARM_DECL:
      TREE_TYPE (t) = load_node ();
      DECL_ARG_TYPE (t) = load_node ();
      DECL_CONTEXT (t) = load_node ();
#ifndef GCC_4_1
      SET_DECL_ASSEMBLER_NAME (t, DECL_NAME (t));
#endif
      break;

    case FIELD_DECL:
      {
        char *assembler_name_str;
        tree f;
        HOST_WIDE_INT n;
        assembler_name_str = load_string (rb.infile);
        if (*assembler_name_str)
          SET_DECL_ASSEMBLER_NAME (t, get_identifier (assembler_name_str));
        free (assembler_name_str);
        TREE_TYPE (t) = load_node ();
#ifndef EGCS97
        bit_position (t) = load_node ();
#else
        DECL_FIELD_BIT_OFFSET (t) = load_node ();
        DECL_FIELD_OFFSET (t) = load_node ();
        LOAD_ANY (n);
        SET_DECL_OFFSET_ALIGN (t, n);
#endif
        DECL_BIT_FIELD_TYPE (t) = load_node ();
        f = load_node ();
        if (f || PASCAL_TREE_DISCRIMINANT (t))
          allocate_decl_lang_specific (t);
        if (f)
          DECL_LANG_FIXUPLIST (t) = f;
        break;
      }

    case CONST_DECL:
      TREE_TYPE (t) = load_node ();
      DECL_INITIAL (t) = load_node ();
      break;

    case LABEL_DECL:
    case RESULT_DECL:
    case TYPE_DECL:
      TREE_TYPE (t) = load_node ();
      break;

    case VAR_DECL:
      {
        char *assembler_name_str;
        tree init;
        TREE_TYPE (t) = load_node ();
#if 1
        init = load_node ();
        if (loading_module_interface && itab == current_interface_table)
          DECL_INITIAL (t) = init;
#endif
        assembler_name_str = load_string (rb.infile);
        gcc_assert (*assembler_name_str);
        SET_DECL_ASSEMBLER_NAME (t, get_identifier (assembler_name_str));
        free (assembler_name_str);
        break;
      }

    case OPERATOR_DECL:
      TREE_TYPE (t) = void_type_node;
      break;

    case PLACEHOLDER_EXPR:
      TREE_TYPE (t) = load_node ();
      break;

#ifdef GCC_4_1
    case CONSTRUCTOR:
      {
        VEC(constructor_elt,gc) *elts = 0;
        tree index, value;
        unsigned HOST_WIDE_INT ix;
        TREE_TYPE (t) = load_node ();
        LOAD_ANY (ix);
        while (ix > 0)
          {
            index = load_node ();
            value = load_node ();
            CONSTRUCTOR_APPEND_ELT (elts, index, value);
            ix--;
          }
        CONSTRUCTOR_ELTS (t) = elts;
      }
      break;
#endif


    default:
      break;
  }
  if (co->debug_gpi)
    {
      fprintf (stderr, "GPI loaded <%i>: ", (int) uid);
      debug_tree (t);
      /* fprintf (stderr, "<%s>\n", tree_code_name[code]); */
    }
  mseek (rb.infile, save_pos);
  return t;
}

/* Create GPI files (GNU Pascal Interface) containing precompiled
   export interfaces of a unit or module. */
void
create_gpi_files (void)
{
  tree escan;
  gcc_assert (!current_module->interface);
  current_module->interface = 1;
  if (co->implementation_only || errorcount || sorrycount)
    return;
  for (escan = current_module->exports; escan; escan = TREE_CHAIN (escan))
    {
      static const gpi_int endianness_marker = GPI_ENDIANNESS_MARKER;
      FILE *s;
      const char *plain_input_filename;
      tree name = TREE_VALUE (escan), iscan, t, imported, nodes;
      char *p, *gpi_file_name = ACONCAT ((IDENTIFIER_POINTER (name), ".gpi", NULL));
      for (p = gpi_file_name; *p; p++)
        *p = TOLOWER (*p);
      if (gpi_destination_path)
        gpi_file_name = ACONCAT ((gpi_destination_path, gpi_file_name, NULL));
      s = fopen (gpi_file_name, "wb");
      if (!s)
        {
          error ("cannot create GPI file `%s'", gpi_file_name);
          exit (FATAL_EXIT_CODE);
        }
      if (co->debug_gpi)
        fprintf (stderr, "creating GPI file: %s\n", gpi_file_name);
      if (co->debug_gpi)
        fprintf (stderr, "GPI storing header: %s", GPI_HEADER);
      store_length_f (s, GPI_HEADER, strlen (GPI_HEADER));
      STORE_ANY_F (s, endianness_marker);
      if (!gpi_version_string)
        gpi_version_string = concat (GPC_VERSION_STRING, GPI_VERSION_ADDITION, version_string, NULL);
      store_string_chunk (s, GPI_CHUNK_VERSION, gpi_version_string);
      store_string_chunk (s, GPI_CHUNK_TARGET, TARGET_NAME);
      store_string_chunk (s, GPI_CHUNK_MODULE_NAME, IDENTIFIER_POINTER (current_module->name));
      plain_input_filename = main_input_filename + strlen (main_input_filename) - 1;
      while (plain_input_filename >= main_input_filename && !IS_DIR_SEPARATOR (*plain_input_filename))
        plain_input_filename--;
      plain_input_filename++;
      store_string_chunk (s, GPI_CHUNK_SRCFILE, plain_input_filename);

      if (co->warn_interface_file_name)
        {
          char *n = ACONCAT ((IDENTIFIER_POINTER (name), NULL));
          char *f = ACONCAT ((plain_input_filename, NULL)), *q = f + strlen (f) - 1;
          while (q >= f && *q != '.')
            q--;
          if (q >= f)
            *q = 0;
          for (q = n; *q; q++)
            *q = TOLOWER (*q);
          if (strcmp (f, n) && strcmp (n + strlen (n) - 4, "-all"))
            gpc_warning ("interface `%s' in file name `%s'", IDENTIFIER_NAME (name), plain_input_filename);
        }

      /* Store names of interfaces imported by this module */
      for (iscan = current_module->imports; iscan; iscan = TREE_CHAIN (iscan))
        if (!TREE_PRIVATE (TREE_VALUE (iscan)))
          {
            /* Store them as strings, not as tree nodes.
               We don't yet want to use the gpi_contents mechanism. */
            tree iname = IMPORT_INTERFACE (TREE_VALUE (iscan));
            const char *name;
            gpi_int l;
            struct interface_table_t *itab;
            gcc_assert (iname && TREE_CODE (iname) == IDENTIFIER_NODE);
            itab = get_interface_table (iname, NULL_TREE);
            gcc_assert (itab->interface_name_node);
            name = IDENTIFIER_POINTER (iname);
            l = strlen (name);
            start_chunk (s, GPI_CHUNK_IMPORT, l + sizeof (itab->gpi_checksum));
            if (l > 0)
              store_length_f (s, name, l);
            STORE_ANY_F (s, itab->gpi_checksum);
            if (co->debug_gpi)
              fprintf (stderr, "GPI storing %s: %s (checksum: %lu)\n",
                               gpi_chunk_names[GPI_CHUNK_IMPORT], name,
                               (unsigned long int) itab->gpi_checksum);
          }
      for (t = current_module->initializers; t; t = TREE_CHAIN (t))
        store_string_chunk (s, GPI_CHUNK_INITIALIZER, IDENTIFIER_POINTER (TREE_VALUE (t)));
      nodes = TREE_PURPOSE (escan);
      module_expand_exported_ranges (nodes);
      imported = NULL_TREE;
      for (imported = current_module->imports; imported && TREE_CHAIN (imported);
           imported = TREE_CHAIN (imported)) ;
      if (imported)
        {
          TREE_CHAIN (imported) = nodes;
          nodes = current_module->imports;
        }
      store_tree (name, s, tree_cons (NULL_TREE, TREE_VALUE (escan), nodes));
      if (imported)
        TREE_CHAIN (imported) = NULL_TREE;
      fclose (s);
    }
}

/* Subroutine of gpi_open(): Search for the source of an interface. */
static char *
locate_interface_source (const char *interface_name, const char *explicit_name, const char *gpi_stored_name)
{
  char *result = NULL;

  /* First try the name given in EXPLICIT_NAME. The user may omit the
     extension and/or use capital letters in the filename. */
  if (explicit_name)
    {
      char *module_filename = alloca (strlen (explicit_name) + 4 + 1), *mfn_end;
      strcpy (module_filename, explicit_name);  /* First, try the given name. */
      mfn_end = strchr (module_filename, 0);
      result = locate_file (module_filename, LF_UNIT);
      if (!result)
        {
          strcpy (mfn_end, ".pas");  /* Next, try extension `.pas' */
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".p");  /* Next, try extension `.p' */
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".pp");  /* Next, try extension `.pp' */
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".dpr");  /* Next, try extension `.dpr' */
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          /* No success yet. But the user did specify the filename
             by a string constant. Try decapitalized version. */
          char *p = module_filename;
          *mfn_end = 0;
          while (*p)
            {
              *p = TOLOWER (*p);
              p++;
            }
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".pas");
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".p");
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".pp");
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".dpr");
          result = locate_file (module_filename, LF_UNIT);
        }
    }
  /* EXPLICIT_NAME not given. Try to derive the source file name from
     the INTERFACE_NAME which is the name of the `.gpi' file. */
  else if (interface_name)
    {
      char *module_filename = alloca (strlen (interface_name) + 4 + 1), *mfn_end;
      strcpy (module_filename, interface_name);
      mfn_end = strchr (module_filename, 0);
      /* Cut the extension `.gpi' */
      do
        mfn_end--;
      while (mfn_end > module_filename && *mfn_end != '.');
      *mfn_end = 0;
      strcpy (mfn_end, ".pas");
      result = locate_file (module_filename, LF_UNIT);
      if (!result)
        {
          strcpy (mfn_end, ".p");
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".pp");
          result = locate_file (module_filename, LF_UNIT);
        }
      if (!result)
        {
          strcpy (mfn_end, ".dpr");
          result = locate_file (module_filename, LF_UNIT);
        }
    }
  /* Last resort: Try the name stored in the GPI file. */
  if (!result && gpi_stored_name)
    result = locate_file (gpi_stored_name, LF_UNIT);
  return result;
}

/* Open a GPI file for reading and process the header and trailer.
   Do an automake, if necessary and/or requested.
   The file is closed via a normal mclose(). */
static MEMFILE *
gpi_open (tree interface_name, const char *name, const char *source, int current_automake_level,
          gpi_int *p_start_of_nodes, gpi_int *p_size_of_nodes, gpi_int *p_size_of_offsets)
{
  MEMFILE *s = NULL;
  char *module_filename = NULL, *source_name = NULL, *temp_name;

  temp_name = locate_file (name, LF_COMPILED_UNIT);
  if (temp_name)
    s = mopen_read (temp_name);

  if (s)
    {
      const char *errstr = NULL;
      int must_recompile = 0, version_set = 0, target_set = 0, module_name_set = 0,
          start_of_nodes = -1, start_of_offsets = -1, source_found = 0;
      tree import_list = NULL_TREE, imported;
      string_list *link_list = NULL;
      char header[sizeof (GPI_HEADER)];
      gpi_int endianness_test_number_read;
      int implementation_flag = 0;

      if (co->debug_gpi)
        fprintf (stderr, "opened GPI file: %s\n", name);
      LOAD_LENGTH_F (s, header, strlen (GPI_HEADER));
      header[strlen (GPI_HEADER)] = 0;
      LOAD_ANY_F (s, endianness_test_number_read);
      if (strcmp (header, GPI_HEADER) != 0)
        errstr = "header mismatch in GPI file `%s'";
      else if (endianness_test_number_read == GPI_INVERSE_ENDIANNESS_MARKER)
        errstr = "GPI files are not portable between hosts with different endianness (`%s')";
      else if (endianness_test_number_read != GPI_ENDIANNESS_MARKER)
        errstr = "invalid endianness marker in GPI file `%s'";
      else
        {
          int abort_flag = 0;
          struct interface_table_t *itab = NULL;
          if (co->debug_gpi)
            fprintf (stderr, "GPI loaded header: %s", header);
          while (!abort_flag && !meof (s))
            {
              unsigned char code;
              gpi_int chunk_size;
              char *str = NULL;
              LOAD_ANY_F (s, code);
              switch (code)
              {
                case GPI_CHUNK_VERSION:
                  str = load_string (s);
                  version_set = 1;
                  if (!gpi_version_string)
                    gpi_version_string = concat (GPC_VERSION_STRING, GPI_VERSION_ADDITION, version_string, NULL);
                  if (strcmp (str, gpi_version_string) != 0)
                    must_recompile = 1;
                  break;
                case GPI_CHUNK_TARGET:
                  str = load_string (s);
                  target_set = 1;
                  if (strcmp (str, TARGET_NAME) != 0)
                    must_recompile = 1;
                  break;
                case GPI_CHUNK_MODULE_NAME:
                  str = load_string (s);
                  module_name_set = 1;
                  itab = get_interface_table (interface_name, get_identifier (str));
                  break;
                case GPI_CHUNK_SRCFILE:
                  str = module_filename = load_string (s);
                  source_name = locate_interface_source (temp_name, source, module_filename);
                  if (source_name)
                    source_found = 1;
                  else
                    source_name = save_string (module_filename);
                  break;
                case GPI_CHUNK_IMPORT:
                  {
                    /* Keep names of imported interfaces for later use. */
                    tree imported, interface;
                    struct interface_table_t *itab;
                    gpi_int l, checksum;
                    LOAD_ANY_F (s, l);
                    l -= sizeof (checksum);
                    str = (char *) xmalloc ((int) l + 1);
                    if (l > 0)
                      LOAD_LENGTH_F (s, str, l);
                    str[l] = 0;
                    LOAD_ANY_F (s, checksum);
                    interface = get_identifier (str);
                    itab = get_interface_table (interface, NULL);
                    if (!itab_check_gpi_checksum (interface, checksum, 0))
                      {
                        if (co->debug_automake)
                          gpc_warning ("`%s' must be recompiled because of checksum mismatch in %s", name, str);
                        must_recompile = 1;
                      }
                    for (imported = current_module->imports; imported; imported = TREE_CHAIN (imported))
                      if (interface == IMPORT_INTERFACE (TREE_VALUE (imported)))
                        break;
                    if (!imported)
                      for (imported = import_list; imported; imported = TREE_CHAIN (imported))
                        if (interface == INTERFACE_TABLE (imported)->interface_name)
                          break;
                    if (!imported)
                      {
                        tree new_import = make_node (INTERFACE_NAME_NODE);
                        INTERFACE_TABLE (new_import) = itab;
                        INTERFACE_CHECKSUM (new_import) = checksum;
                        import_list = chainon (import_list, new_import);
                      }
                    break;
                  }
                case GPI_CHUNK_LINK:
                  {
                    /* Keep names of link files for later use. */
                    char *object_file_name;
                    str = load_string (s);
                    object_file_name = locate_file (str, LF_OBJECT);
                    if (object_file_name)
                      append_string_list (&link_list, object_file_name, 0);
                    else
                      must_recompile = 1;
                    break;
                  }
                case GPI_CHUNK_LIB:
                  str = load_string (s);
                  append_string_list (&link_list, str, 0);
                  break;
                case GPI_CHUNK_INITIALIZER:
                  str = load_string (s);
                  if (!itab)
                    errstr = "wrong order of chunks in GPI file `%s'";
                  else
                    itab->initializers = chainon (itab->initializers,
                      build_tree_list (NULL_TREE, get_identifier (str)));
                  break;
                case GPI_CHUNK_GPC_MAIN_NAME:
                  gpc_main = load_string (s);
                  break;
                case GPI_CHUNK_NODES:
                  LOAD_ANY_F (s, chunk_size);
                  start_of_nodes = mtell (s);
                  if (p_start_of_nodes)
                    *p_start_of_nodes = start_of_nodes;
                  if (p_size_of_nodes)
                    *p_size_of_nodes = chunk_size;
                  mseek (s, mtell (s) + chunk_size);
                  break;
                case GPI_CHUNK_OFFSETS:
                  LOAD_ANY_F (s, chunk_size);
                  start_of_offsets = mtell (s);
                  if (p_size_of_offsets)
                    *p_size_of_offsets = chunk_size;
                  mseek (s, mtell (s) + chunk_size);
                  break;
                case GPI_CHUNK_IMPLEMENTATION:
                  LOAD_ANY_F (s, chunk_size);
                  if (chunk_size != 0)
                    {
                      mseek (s, mtell (s) + chunk_size);
                      errstr = "implementation flag in GPI file `%s' contains unexpected data";
                    }
#if 0
                  else if (implementation_flag)
                    gpc_warning ("duplicate implementation flag in GPI file `%s'", name);
#endif
                  implementation_flag = 1;
                  break;
                default:
                  errstr = "unknown chunk in GPI file `%s'";
                  abort_flag = 1;  /* file may be damaged, try to avoid crashing */
              }
              if (str && co->debug_gpi)
                fprintf (stderr, "GPI loaded %s: %s\n", gpi_chunk_names[code], str);
            }
          if (errstr)
            ;
          else if (!version_set)
            errstr = "GPI file `%s' does not contain version chunk";
          else if (!target_set)
            errstr = "GPI file `%s' does not contain target chunk";
          else if (!module_name_set)
            errstr = "GPI file `%s' does not contain module name chunk";
          else if (!module_filename)
            errstr = "GPI file `%s' does not contain source file name chunk";
          else if (start_of_nodes < 0)
            errstr = "GPI file `%s' does not contain nodes chunk";
          else if (start_of_offsets < 0)
            errstr = "GPI file `%s' does not contain offsets chunk";
          else
            {
              mseek (s, start_of_offsets);  /* Position the file for a later load_tree() */

              if (current_automake_level > 1)
                /* Check modules used by the one being imported. */
                for (imported = import_list; imported && !must_recompile; imported = TREE_CHAIN (imported))
                  {
                    MEMFILE *u;
                    char *p, *u_name = ACONCAT ((IDENTIFIER_POINTER (INTERFACE_TABLE (imported)->interface_name), ".gpi", NULL));
                    for (p = u_name; *p; p++)
                      *p = TOLOWER (*p);
                    if (co->automake_level && find_automake_tempfile_entry ("#up to date: ", u_name, 1))
                      {
                        if (co->debug_automake)
                          fprintf (stderr, "GPI import check: `%s' marked as up to date\n", u_name);
                      }
                    else
                      {
                        if (co->debug_automake)
                          fprintf (stderr, "GPI import check: tentatively opening `%s'\n", u_name);
                        u = gpi_open (INTERFACE_TABLE (imported)->interface_name, u_name, NULL, current_automake_level, NULL, NULL, NULL);
                        if (u)
                          mclose (u);
                        else
                          must_recompile = 1;
                      }
                  }
            }
        }
      if (errstr)
        {
          gpc_warning (errstr, name);
          module_filename = NULL;
          must_recompile = 1;
        }

      /* @@@@ The code of module_must_be_recompiled() should be moved to the right places
              within this function. E.g., autobuild should be checked at the beginning.
              But it must check if the file is already being compiled, so it should
              probably be near the actual recompilation code below (e.g., it's not good
              to call find_automake_tempfile_entry() twice (see compile_module()). Since
              automake is going to disappear in the future, the trouble may not be
              worth doing it. -- Frank */
      if (!(current_automake_level > 1
            && !(source_found && find_automake_tempfile_entry ("#compiling: ", source_name, 1))
            && (must_recompile || (source_found && module_must_be_recompiled (interface_name, temp_name, source_name, import_list)))))
        {
          char *object_filename;

          if (errstr)
            {
              /* We get here if an error was just output, but recompilation is
                 prevented by the user or the fact that we're retrying already,
                 or the module is in a file already being compiled. */
              error ("cannot recompile module");
              exit (FATAL_EXIT_CODE);
            }

          if (must_recompile)
            {
              error ("`%s' must be recompiled", name);
              exit (FATAL_EXIT_CODE);
            }

          name = temp_name;  /* Don't do this until here when we know that the GPI file is valid */

          /* Tell the linker about the object file. */
          object_filename = locate_object_file (source_name);
          if (object_filename)
            {
              add_to_link_file_list (object_filename);
              free (object_filename);
            }
          /* else  @@ wrong if in current file (mod9.pas)
            error ("object file `%s' not found", object_filename); */

          /* Record modules used by the one being imported as
             "implementation imports" for the one being compiled.
             Also mark them as being imported implicitly. */
          for (imported = import_list; imported; imported = TREE_CHAIN (imported))
            itab_check_gpi_checksum (INTERFACE_TABLE (imported)->interface_name,
              INTERFACE_CHECKSUM (imported), 1);

          /* Copy names of files to be linked to the automake temp file. */
          while (link_list)
            {
              add_to_link_file_list (link_list->string);
              link_list = link_list->next;
            }
        }
      else
        {
          mclose (s);
          s = NULL;
          if (co->debug_automake)
            fprintf (stderr, "recompiling: %s -> %s\n", module_filename, name);
          /* "fallthrough" */
        }
    }
  if (!s && current_automake_level > 1)
    {
      int result = -1;
      if (!module_filename)
        {
          source_name = locate_interface_source (name, source, NULL);
          module_filename = save_string (name);
        }
      if (source_name)
        result = compile_module (source_name, unit_destination_path);
      if (result == 0)
        {
          /* Module has been compiled. Reload the GPI file. Don't compile again. */
          if (co->debug_automake)
            fprintf (stderr, "Compilation done. Reloading `%s'.\n", name);
          add_to_automake_temp_file (ACONCAT (("#up to date: ", name, NULL)));
          /* @@ Replace recursive call with a loop */
          s = gpi_open (interface_name, name, source, 0, p_start_of_nodes, p_size_of_nodes, p_size_of_offsets);
        }
      else if (co->automake_level > 1)
        {
          if (!source)
            {
              /* Cut the extension `.gpi' */
              char *p = module_filename + strlen (module_filename);
              while (p > module_filename && *p != '.')
                p--;
              *p = 0;
              source = module_filename;
            }
          error ("module/unit `%s' could not be compiled", source);
          exit (FATAL_EXIT_CODE);
        }
    }
  if (temp_name)
    free (temp_name);
  if (module_filename)
    free (module_filename);
  if (source_name)
    free (source_name);
  return s;
}

/* Try to load a GPI file and to extract an exported module interface. */
static tree
load_gpi_file (tree interface_name, const char *source, int module_interface)
{
  MEMFILE *gpi_file;
  gpi_int start_of_nodes, size_of_nodes, size_of_offsets;
  tree temp;
  gpi_int checksum;
  size_t oldpos;
  char *p, *current_gpi_file_name = ACONCAT ((IDENTIFIER_POINTER (interface_name), ".gpi", NULL));
  struct interface_table_t *save_current_interface_table = current_interface_table;
  current_interface_table = get_interface_table (interface_name, NULL_TREE);
  for (p = current_gpi_file_name; *p; p++)
    *p = TOLOWER (*p);
  gpi_file = gpi_open (interface_name, current_gpi_file_name, source, module_interface ? 0 : co->automake_level, &start_of_nodes, &size_of_nodes, &size_of_offsets);
  if (!gpi_file)
    {
      if (module_interface)
        error ("could not load interface module of module `%s'", IDENTIFIER_NAME (current_module->name));
      else
        error ("module/unit interface `%s' could not be imported", IDENTIFIER_NAME (interface_name));
      exit (FATAL_EXIT_CODE);
    }
  oldpos = mtell (gpi_file);
  mseek (gpi_file, start_of_nodes + size_of_nodes - sizeof (checksum));
  LOAD_ANY_F (gpi_file, checksum);
  mseek (gpi_file, oldpos);
  if (compute_checksum (mptr (gpi_file, start_of_nodes), size_of_nodes - sizeof (checksum)) != checksum)
    {
      error ("%s: checksum mismatch (GPI file corrupt)", current_gpi_file_name);
      exit (FATAL_EXIT_CODE);
    }
  itab_check_gpi_checksum (interface_name, checksum, 1);
  temp = load_tree (gpi_file, start_of_nodes, size_of_offsets, module_interface);
  TREE_PURPOSE (temp) = TREE_CHAIN (temp);
  TREE_CHAIN (temp) = NULL_TREE;
  mclose (gpi_file);
  current_interface_table = save_current_interface_table;
  return temp;
}

/* Activate a node during import */
static void
import_node (tree item, tree rename, tree interface, import_type qualified)
{
  tree value = TREE_PURPOSE (item);
  int no_principal = rename && TREE_CODE (value) == CONST_DECL;
  rename = rename ? rename : TREE_VALUE (item);
  if (TREE_CODE (TREE_VALUE (item)) == IMPORT_NODE)
    return;
  TREE_READONLY (value) |= TREE_READONLY (item);
  if (TREE_CODE (value) == FUNCTION_DECL && DECL_LANG_OPERATOR_DECL (value))
    operators_defined = 1;
  if (qualified == IMPORT_ISO || qualified == IMPORT_USES)
    {
      tree decl1 = interface ? copy_node (value) : value;
      DECL_NAME (decl1) = rename;
      PASCAL_DECL_WEAK (decl1) = 0;
      PASCAL_DECL_IMPORTED (decl1) = 1;
      if (no_principal)
        PASCAL_CST_PRINCIPAL_ID (decl1) = 0;
      pushdecl_import (decl1, qualified == IMPORT_USES);
    }
  if (interface)
    {
      tree qdecl = copy_node (value);
      tree qid = build_qualified_id (interface, rename);
      DECL_NAME (qdecl) = qid;
      PASCAL_DECL_WEAK (qdecl) = 0;
      PASCAL_DECL_IMPORTED (qdecl) = 1;
      if (no_principal)
        PASCAL_CST_PRINCIPAL_ID (qdecl) = 0;
      pushdecl_import (qdecl, 0);
    }
  TREE_USED (item) = 1;
  if (co->propagate_units)
    handle_autoexport (rename ? rename : TREE_VALUE (item));
}

/* Load the complete interface part of this unit or module. */
static void
load_own_interface (int is_module)
{
  tree interface_name, exported, ename, t;
  gcc_assert (!current_module->implementation);
  current_module->implementation = 1;
  if (is_module)
    interface_name = get_identifier (ACONCAT ((IDENTIFIER_POINTER (current_module->name), "-all", NULL)));
  else
    interface_name = get_identifier (IDENTIFIER_POINTER (current_module->name));
  exported = load_gpi_file (interface_name, NULL, 1);
  /* Activate all names. */
  for (ename = TREE_PURPOSE (exported); ename; ename = TREE_CHAIN (ename))
    if (TREE_CODE (TREE_VALUE (ename)) == IMPORT_NODE)
      {
        tree t = TREE_VALUE (ename);
        import_interface (IMPORT_INTERFACE (t), IMPORT_QUALIFIER (t),
                          PASCAL_TREE_QUALIFIED (t), IMPORT_FILENAME (t));
      }
    else
      {
        t = TREE_PURPOSE (ename);
        if (TREE_CODE (t) == FUNCTION_DECL && PASCAL_FORWARD_DECLARATION (t))
          set_forward_decl (t, 1);
        import_node (ename, NULL_TREE, NULL_TREE, IMPORT_ISO);
      }
  current_module->initializers = itab_get_initializers (interface_name);  /* @@ use any interface name */
}

/* Import an interface of a unit or module. Look up and read the
   GPI file and import either everything or only the requested parts
   exported by the interface.

   INTERFACE is an IDENTIFIER_NODE of the interface name.

   IMPORT_QUALIFIER:
     NULL_TREE if no qualifiers given.
     TREE_LIST:
       TREE_PURPOSE: IDENTIFIER_NODE (`only') or NULL_TREE
       TREE_VALUE:
        TREE_LIST:
         TREE_PURPOSE: imported name from the interface
         TREE_VALUE: renamed name (IDENTIFIER_NODE) or NULL_TREE

   QUALIFIED_IMPORT is 0 if unqualified references are allowed;
                       1 if qualified references are mandatory.

   FILENAME is an optional IDENTIFIER_NODE holding the name of the
   source file. */
void
import_interface (tree interface, tree import_qualifier, import_type qualified, tree filename)
{
  tree exported_name_list, imported, exported, ename, iname;
  tree import_decl;
  struct predef *pd;
#ifndef EGCS97
  struct obstack *ambient_obstack = current_obstack;
  current_obstack = &permanent_obstack;
#endif

  if (filename && TREE_CODE (filename) != STRING_CST)
    {
      error ("module/unit file name is no string constant");
      filename = NULL_TREE;
    }
  /* Handle a special case of a circular dependency. */
  if (interface == current_module->name && current_module->bp_qualids)
    {
      if (current_module->main_program)
        {
          error ("program with Borland Pascal style quailified identifiers");
          error (" trying to import itself like a module or unit");
        }
      else
        error ("self-dependent unit");
      return;
    }
  for (exported = current_module->exports; exported; exported = TREE_CHAIN (exported))
    if (TREE_VALUE (exported) == interface)
      {
        error ("self-dependent module, interface `%s'", IDENTIFIER_NAME (interface));
        return;
      }
  import_decl = lookup_name_current_level (interface);
  if (import_decl && TREE_CODE (import_decl) == NAMESPACE_DECL)
    {
      error ("interface `%s' has already been imported", IDENTIFIER_NAME (interface));
      return;
    }
  import_decl = build_decl (NAMESPACE_DECL, interface, void_type_node);
  pushdecl (import_decl);
  for (imported = current_module->imports; imported; imported = TREE_CHAIN (imported))
    if (interface == IMPORT_INTERFACE (TREE_VALUE (imported)))
      break;

  if (!imported)
    {
      tree t = make_node (IMPORT_NODE);
      IMPORT_INTERFACE (t) = interface;
      IMPORT_QUALIFIER (t) = import_qualifier;
      PASCAL_TREE_QUALIFIED (t) = qualified;
      IMPORT_FILENAME (t) = filename;
      imported = build_tree_list (NULL_TREE, t);
      current_module->imports = chainon (current_module->imports, imported);
    }

  pd = IDENTIFIER_BUILT_IN_VALUE (interface);
  if (PD_ACTIVE (pd) && pd->kind == bk_interface)
    {
      tree decl;
      chk_dialect_name (IDENTIFIER_NAME (interface), pd->dialect);
      (void) get_interface_table (interface, interface);  /* initializers is NULL_TREE */
      itab_check_gpi_checksum (interface, 0, 1);
      if (IDENTIFIER_IS_BUILT_IN (interface, p_StandardInput))
        {
          current_module->input_available = 1;
          decl = input_variable_node;
        }
      else if (IDENTIFIER_IS_BUILT_IN (interface, p_StandardOutput))
        {
          current_module->output_available = 1;
          decl = output_variable_node;
        }
      else if (IDENTIFIER_IS_BUILT_IN (interface, p_StandardError))
        decl = error_variable_node;
      else
        gcc_unreachable ();
      exported_name_list = build_tree_list (decl, DECL_NAME (decl));
      TREE_PRIVATE (TREE_VALUE (imported)) = 1;
    }
  else
    {
      for (exported = exported_interface_list; exported; exported = TREE_CHAIN (exported))
        if (TREE_VALUE (exported) == interface)
          break;

      if (!exported)
        {
          const char *gpi_source;
          if (filename)
            gpi_source = TREE_STRING_POINTER (filename);
          else
            gpi_source = NULL;
          exported = load_gpi_file (interface, gpi_source, 0);
          exported_interface_list = tree_cons (TREE_PURPOSE (exported), interface, exported_interface_list);
        }
      exported_name_list = TREE_PURPOSE (exported);
    }

  for (ename = exported_name_list; ename; ename = TREE_CHAIN (ename))
    TREE_USED (ename) = 0;
  if (import_qualifier)
    for (iname = TREE_VALUE (import_qualifier); iname; iname = TREE_CHAIN (iname))
      {
        tree ename = exported_name_list;
        while (ename && TREE_VALUE (ename) != TREE_PURPOSE (iname))
          ename = TREE_CHAIN (ename);
        /* Activate this name and resolve possible import renaming. */
        if (ename)
          import_node (ename, TREE_VALUE (iname), interface, qualified);
        else
          error ("interface `%s' does not export `%s'",
                 IDENTIFIER_NAME (interface), IDENTIFIER_NAME (TREE_PURPOSE (iname)));
      }

  /* Without `only', activate all [remaining] names. */
  if (!(import_qualifier && TREE_PURPOSE (import_qualifier)))
    for (ename = exported_name_list; ename; ename = TREE_CHAIN (ename))
      if (!TREE_USED (ename))
        import_node (ename, NULL_TREE, interface, qualified);
#ifndef EGCS97
    current_obstack = ambient_obstack;
#endif
}

/* Replace the exported TREE_LISTs denoting ranges by the actual identifier
   nodes. These need special care because they contain identifiers in between
   which must be exported as well. */
static void
module_expand_exported_ranges (tree list)
{
  tree t;
  for (t = list; t; t = TREE_CHAIN (t))
    if (TREE_VALUE (t) && TREE_CODE (TREE_VALUE (t)) == TREE_LIST)
      {
        tree low = TREE_PURPOSE (TREE_VALUE (t));
        tree high = TREE_VALUE (TREE_VALUE (t));
        tree tlow = lookup_name (low);
        tree thigh = lookup_name (high);
        tree exported = NULL_TREE;
        tree item;
        int export_it = 0;
        TREE_VALUE (t) = NULL_TREE;  /* Remove the range TREE_LIST */
        if (tlow
            && thigh
            && TREE_CODE (tlow) == CONST_DECL
            && TREE_CODE (thigh) == CONST_DECL
            && TREE_CODE (TREE_TYPE (tlow)) == ENUMERAL_TYPE
            && TREE_TYPE (thigh) == TREE_TYPE (tlow))
          for (item = TYPE_VALUES (TREE_TYPE (tlow)); item; item = TREE_CHAIN (item))
            {
              if (tree_int_cst_equal (TREE_VALUE (item), DECL_INITIAL (tlow)))
                export_it = 1;
              if (export_it)
                {
                  tree id = TREE_PURPOSE (item);
                  tree tid = lookup_name (id);
                  if (!tid || TREE_CODE (tid) != CONST_DECL
                      || DECL_INITIAL (tid) != TREE_VALUE (item)
                      || !PASCAL_CST_PRINCIPAL_ID (tid))
                    {
                      error ("cannot export range value `%s',",
                             IDENTIFIER_NAME (id));
                      error (" principal identifier not in scope");
                    }
                   else
                     exported = tree_cons (NULL_TREE, id, exported);
                }
              if (tree_int_cst_equal (TREE_VALUE (item), DECL_INITIAL (thigh)))
                {
                  if (!export_it)
                    error ("wrong order in exported range");
                  export_it = 0;
                }
            }
        /* Chain EXPORTED to t. */
        if (exported)
          {
            tree new = exported;
            exported = nreverse (exported);  /* `new' now points to the end of `exported'! */
            TREE_CHAIN (new) = TREE_CHAIN (t);
            TREE_CHAIN (t) = exported;
            t = new;
          }
        else
          error ("invalid exported range `%s .. %s'", IDENTIFIER_NAME (low), IDENTIFIER_NAME (high));
      }
}

#ifdef GCC_3_3
#include "gt-p-module.h"
#endif
