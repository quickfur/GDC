This patch implements the support for the D language specific target hooks.

The following versions are available for all supported architectures.
* D_HardFloat
* D_SoftFloat

The following CPU versions are implemented:
* Epiphany
* IA64
* NVPTX
* NVPTX64
* RISCV32
* RISCV64

The following OS versions are implemented:
* Windows
** Win32
** Win64
** Cygwin
** MinGW
* OSX
** darwin (deprecated)
* FreeBSD
* OpenBSD
* NetBSD
* DragonFlyBSD
* Solaris
* Posix

These official OS versions are not implemented:
* AIX
* BSD (other BSDs)
* Haiku
* PlayStation
* PlayStation4
* SkyOS
* SysV3
* SysV4
* CRuntime_DigitalMars
* CRuntime_Microsoft
---
 
--- a/gcc/config.gcc
+++ b/gcc/config.gcc
@@ -356,6 +356,9 @@ bfin*-*)
 crisv32-*)
 	cpu_type=cris
 	;;
+epiphany-*-* )
+	d_target_objs="epiphany-d.o"
+	;;
 frv*)	cpu_type=frv
 	extra_options="${extra_options} g.opt"
 	;;
@@ -419,6 +422,7 @@ x86_64-*-*)
 		       clzerointrin.h pkuintrin.h sgxintrin.h"
 	;;
 ia64-*-*)
+	d_target_objs="ia64-d.o"
 	extra_headers=ia64intrin.h
 	extra_options="${extra_options} g.opt fused-madd.opt"
 	;;
@@ -458,6 +462,7 @@ nios2-*-*)
 	;;
 nvptx-*-*)
 	cpu_type=nvptx
+	d_target_objs="nvptx-d.o"
 	;;
 powerpc*-*-*spe*)
 	cpu_type=powerpcspe
@@ -486,6 +491,7 @@ powerpc*-*-*)
 riscv*)
 	cpu_type=riscv
 	extra_objs="riscv-builtins.o riscv-c.o"
+	d_target_objs="riscv-d.o"
 	;;
 rs6000*-*-*)
 	extra_options="${extra_options} g.opt fused-madd.opt rs6000/rs6000-tables.opt"
@@ -672,8 +678,10 @@ case ${target} in
   extra_options="${extra_options} darwin.opt"
   c_target_objs="${c_target_objs} darwin-c.o"
   cxx_target_objs="${cxx_target_objs} darwin-c.o"
+  d_target_objs="${d_target_objs} darwin-d.o"
   fortran_target_objs="darwin-f.o"
   target_has_targetcm=yes
+  target_has_targetdm=yes
   extra_objs="darwin.o"
   extra_gcc_objs="darwin-driver.o"
   default_use_cxa_atexit=yes
@@ -698,6 +706,9 @@ case ${target} in
       exit 1
       ;;
   esac
+  d_target_objs="${d_target_objs} dragonfly-d.o"
+  target_has_targetdm=yes
+  tmake_file="${tmake_file} t-dragonfly"
   extra_options="$extra_options rpath.opt dragonfly.opt"
   default_use_cxa_atexit=yes
   use_gcc_stdint=wrap
@@ -741,6 +752,9 @@ case ${target} in
       ;;
   esac
   fbsd_tm_file="${fbsd_tm_file} freebsd-spec.h freebsd.h freebsd-stdint.h"
+  d_target_objs="${d_target_objs} freebsd-d.o"
+  target_has_targetdm=yes
+  tmake_file="${tmake_file} t-freebsd"
   extra_options="$extra_options rpath.opt freebsd.opt"
   case ${target} in
     *-*-freebsd[345].*)
@@ -816,6 +830,9 @@ case ${target} in
   gas=yes
   gnu_ld=yes
   use_gcc_stdint=wrap
+  d_target_objs="${d_target_objs} netbsd-d.o"
+  target_has_targetdm=yes
+  tmake_file="${tmake_file} t-netbsd"
 
   # NetBSD 2.0 and later get POSIX threads enabled by default.
   # Allow them to be explicitly enabled on any other version.
@@ -844,6 +861,8 @@ case ${target} in
   ;;
 *-*-openbsd*)
   tmake_file="t-openbsd"
+  d_target_objs="${d_target_objs} netbsd-d.o"
+  target_has_targetdm=yes
   case ${enable_threads} in
     yes)
       thread_file='posix'
@@ -909,6 +928,8 @@ case ${target} in
   tmake_file="${tmake_file} t-sol2 t-slibgcc"
   c_target_objs="${c_target_objs} sol2-c.o"
   cxx_target_objs="${cxx_target_objs} sol2-c.o sol2-cxx.o"
+  d_target_objs="${d_target_objs} sol2-d.o"
+  target_has_targetdm="yes"
   extra_objs="sol2.o sol2-stubs.o"
   extra_options="${extra_options} sol2.opt"
   case ${enable_threads}:${have_pthread_h}:${have_thread_h} in
@@ -1747,7 +1768,9 @@ i[34567]86-*-mingw* | x86_64-*-mingw*)
 	xm_file=i386/xm-mingw32.h
 	c_target_objs="${c_target_objs} winnt-c.o"
 	cxx_target_objs="${cxx_target_objs} winnt-c.o"
+	d_target_objs="${d_target_objs} winnt-d.o"
 	target_has_targetcm="yes"
+	target_has_targetdm="yes"
 	case ${target} in
 		x86_64-*-* | *-w64-*)
 			need_64bit_isa=yes
--- a/gcc/config/darwin-d.c
+++ b/gcc/config/darwin-d.c
@@ -0,0 +1,55 @@
+/* Darwin support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "tm_d.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_OS_VERSIONS for Darwin targets.  */
+
+static void
+darwin_d_os_builtins (void)
+{
+  d_add_builtin_version ("OSX");
+  d_add_builtin_version ("darwin");
+  d_add_builtin_version ("Posix");
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for Darwin targets.  */
+
+static unsigned
+darwin_d_critsec_size (void)
+{
+  /* This is the sizeof pthread_mutex_t.  */
+  if (TYPE_PRECISION (long_integer_type_node) == 64
+      && POINTER_SIZE == 64
+      && TYPE_PRECISION (integer_type_node) == 32)
+    return 64;
+  else
+    return 44;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS darwin_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE darwin_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/dragonfly-d.c
+++ b/gcc/config/dragonfly-d.c
@@ -0,0 +1,49 @@
+/* DragonFly support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "tm_d.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_OS_VERSIONS for DragonFly targets.  */
+
+static void
+dragonfly_d_os_builtins (void)
+{
+  d_add_builtin_version ("DragonFlyBSD");
+  d_add_builtin_version ("Posix");
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for DragonFly targets.  */
+
+static unsigned
+dragonfly_d_critsec_size (void)
+{
+  /* This is the sizeof pthread_mutex_t, an opaque pointer.  */
+  return POINTER_SIZE_UNITS;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS dragonfly_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE dragonfly_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/epiphany/epiphany-d.c
+++ b/gcc/config/epiphany/epiphany-d.c
@@ -0,0 +1,31 @@
+/* Subroutines for the D front end on the EPIPHANY architecture.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify
+it under the terms of the GNU General Public License as published by
+the Free Software Foundation; either version 3, or (at your option)
+any later version.
+
+GCC is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+GNU General Public License for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_CPU_VERSIONS for EPIPHANY targets.  */
+
+void
+epiphany_d_target_versions (void)
+{
+  d_add_builtin_version ("Epiphany");
+  d_add_builtin_version ("D_HardFloat");
+}
--- a/gcc/config/epiphany/epiphany-protos.h
+++ b/gcc/config/epiphany/epiphany-protos.h
@@ -61,3 +61,5 @@ extern bool epiphany_regno_rename_ok (unsigned src, unsigned dst);
    it uses peephole2 predicates without having all the necessary headers.  */
 extern int get_attr_sched_use_fpu (rtx_insn *);
 
+/* Routines implemented in epiphany-d.c  */
+extern void epiphany_d_target_versions (void);
--- a/gcc/config/epiphany/epiphany.h
+++ b/gcc/config/epiphany/epiphany.h
@@ -41,6 +41,9 @@ along with GCC; see the file COPYING3.  If not see
 	builtin_assert ("machine=epiphany");	\
     } while (0)
 
+/* Target CPU versions for D.  */
+#define TARGET_D_CPU_VERSIONS epiphany_d_target_versions
+
 /* Pick up the libgloss library. One day we may do this by linker script, but
    for now its static.
    libgloss might use errno/__errno, which might not have been needed when we
--- a/gcc/config/epiphany/t-epiphany
+++ b/gcc/config/epiphany/t-epiphany
@@ -36,3 +36,7 @@ specs: specs.install
 	sed -e 's,epiphany_library_extra_spec,epiphany_library_stub_spec,' \
 	-e 's,epiphany_library_build_spec,epiphany_library_extra_spec,' \
 	  < specs.install > $@ ; \
+
+epiphany-d.o: $(srcdir)/config/epiphany/epiphany-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/freebsd-d.c
+++ b/gcc/config/freebsd-d.c
@@ -0,0 +1,49 @@
+/* FreeBSD support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "tm_d.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_OS_VERSIONS for FreeBSD targets.  */
+
+static void
+freebsd_d_os_builtins (void)
+{
+  d_add_builtin_version ("FreeBSD");
+  d_add_builtin_version ("Posix");
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for FreeBSD targets.  */
+
+static unsigned
+freebsd_d_critsec_size (void)
+{
+  /* This is the sizeof pthread_mutex_t, an opaque pointer.  */
+  return POINTER_SIZE_UNITS;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS freebsd_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE freebsd_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/i386/cygwin.h
+++ b/gcc/config/i386/cygwin.h
@@ -29,6 +29,12 @@ along with GCC; see the file COPYING3.  If not see
     }								\
   while (0)
 
+#define EXTRA_TARGET_D_OS_VERSIONS()				\
+    do {							\
+      builtin_version ("Cygwin");				\
+      builtin_version ("Posix");				\
+    } while (0)
+
 #undef CPP_SPEC
 #define CPP_SPEC "%(cpp_cpu) %{posix:-D_POSIX_SOURCE} \
   %{!ansi:-Dunix} \
--- a/gcc/config/i386/mingw32.h
+++ b/gcc/config/i386/mingw32.h
@@ -53,6 +53,16 @@ along with GCC; see the file COPYING3.  If not see
     }								\
   while (0)
 
+#define EXTRA_TARGET_D_OS_VERSIONS()				\
+    do {							\
+      builtin_version ("MinGW");				\
+								\
+      if (TARGET_64BIT && ix86_abi == MS_ABI)			\
+	  builtin_version ("Win64");				\
+      else if (!TARGET_64BIT)					\
+        builtin_version ("Win32");				\
+    } while (0)
+
 #ifndef TARGET_USE_PTHREAD_BY_DEFAULT
 #define SPEC_PTHREAD1 "pthread"
 #define SPEC_PTHREAD2 "!no-pthread"
--- a/gcc/config/i386/t-cygming
+++ b/gcc/config/i386/t-cygming
@@ -32,6 +32,9 @@ winnt-cxx.o: $(srcdir)/config/i386/winnt-cxx.c $(CONFIG_H) $(SYSTEM_H) coretypes
 	$(COMPILER) -c $(ALL_COMPILERFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
 	$(srcdir)/config/i386/winnt-cxx.c
 
+winnt-d.o: config/winnt-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
 
 winnt-stubs.o: $(srcdir)/config/i386/winnt-stubs.c $(CONFIG_H) $(SYSTEM_H) coretypes.h \
   $(TM_H) $(RTL_H) $(REGS_H) hard-reg-set.h output.h $(TREE_H) flags.h \
--- a/gcc/config/i386/winnt-d.c
+++ b/gcc/config/i386/winnt-d.c
@@ -0,0 +1,60 @@
+/* Windows support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "target.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+#include "tm_p.h"
+
+/* Implement TARGET_D_OS_VERSIONS for Windows targets.  */
+
+static void
+winnt_d_os_builtins (void)
+{
+  d_add_builtin_version ("Windows");
+
+#define builtin_version(TXT) d_add_builtin_version (TXT)
+
+#ifdef EXTRA_TARGET_D_OS_VERSIONS
+  EXTRA_TARGET_D_OS_VERSIONS ();
+#endif
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for Windows targets.  */
+
+static unsigned
+winnt_d_critsec_size (void)
+{
+  /* This is the sizeof CRITICAL_SECTION.  */
+  if (TYPE_PRECISION (long_integer_type_node) == 64
+      && POINTER_SIZE == 64
+      && TYPE_PRECISION (integer_type_node) == 32)
+    return 40;
+  else
+    return 24;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS winnt_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE winnt_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/ia64/ia64-d.c
+++ b/gcc/config/ia64/ia64-d.c
@@ -0,0 +1,31 @@
+/* Subroutines for the D front end on the IA64 architecture.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify
+it under the terms of the GNU General Public License as published by
+the Free Software Foundation; either version 3, or (at your option)
+any later version.
+
+GCC is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+GNU General Public License for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_CPU_VERSIONS for IA64 targets.  */
+
+void
+ia64_d_target_versions (void)
+{
+  d_add_builtin_version ("IA64");
+  d_add_builtin_version ("D_HardFloat");
+}
--- a/gcc/config/ia64/ia64-protos.h
+++ b/gcc/config/ia64/ia64-protos.h
@@ -98,6 +98,9 @@ extern void ia64_hpux_handle_builtin_pragma (struct cpp_reader *);
 extern void ia64_output_function_profiler (FILE *, int);
 extern void ia64_profile_hook (int);
 
+/* Routines implemented in ia64-d.c  */
+extern void ia64_d_target_versions (void);
+
 extern void ia64_init_expanders (void);
 
 extern rtx ia64_dconst_0_5 (void);
--- a/gcc/config/ia64/ia64.h
+++ b/gcc/config/ia64/ia64.h
@@ -40,6 +40,9 @@ do {						\
 	  builtin_define("__BIG_ENDIAN__");	\
 } while (0)
 
+/* Target CPU versions for D.  */
+#define TARGET_D_CPU_VERSIONS ia64_d_target_versions
+
 #ifndef SUBTARGET_EXTRA_SPECS
 #define SUBTARGET_EXTRA_SPECS
 #endif
--- a/gcc/config/ia64/t-ia64
+++ b/gcc/config/ia64/t-ia64
@@ -21,6 +21,10 @@ ia64-c.o: $(srcdir)/config/ia64/ia64-c.c $(CONFIG_H) $(SYSTEM_H) \
 	$(COMPILER) -c $(ALL_COMPILERFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
 		$(srcdir)/config/ia64/ia64-c.c
 
+ia64-d.o: $(srcdir)/config/ia64/ia64-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
+
 # genattrtab generates very long string literals.
 insn-attrtab.o-warn = -Wno-error
 
--- a/gcc/config/netbsd-d.c
+++ b/gcc/config/netbsd-d.c
@@ -0,0 +1,49 @@
+/* NetBSD support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "tm_d.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_OS_VERSIONS for NetBSD targets.  */
+
+static void
+netbsd_d_os_builtins (void)
+{
+  d_add_builtin_version ("NetBSD");
+  d_add_builtin_version ("Posix");
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for NetBSD targets.  */
+
+static unsigned
+netbsd_d_critsec_size (void)
+{
+  /* This is the sizeof pthread_mutex_t.  */
+  return 48;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS netbsd_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE netbsd_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/nvptx/nvptx-d.c
+++ b/gcc/config/nvptx/nvptx-d.c
@@ -0,0 +1,34 @@
+/* Subroutines for the D front end on the NVPTX architecture.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify
+it under the terms of the GNU General Public License as published by
+the Free Software Foundation; either version 3, or (at your option)
+any later version.
+
+GCC is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+GNU General Public License for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "target.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_CPU_VERSIONS for NVPTX targets.  */
+
+void
+nvptx_d_target_versions (void)
+{
+  if (TARGET_ABI64)
+    d_add_builtin_version ("NVPTX64");
+  else
+    d_add_builtin_version ("NVPTX");
+}
--- a/gcc/config/nvptx/nvptx-protos.h
+++ b/gcc/config/nvptx/nvptx-protos.h
@@ -42,6 +42,9 @@ extern void nvptx_output_skip (FILE *, unsigned HOST_WIDE_INT);
 extern void nvptx_output_ascii (FILE *, const char *, unsigned HOST_WIDE_INT);
 extern void nvptx_register_pragmas (void);
 
+/* Routines implemented in nvptx-d.c  */
+extern void nvptx_d_target_versions (void);
+
 #ifdef RTX_CODE
 extern void nvptx_expand_oacc_fork (unsigned);
 extern void nvptx_expand_oacc_join (unsigned);
--- a/gcc/config/nvptx/nvptx.h
+++ b/gcc/config/nvptx/nvptx.h
@@ -37,6 +37,9 @@
         builtin_define ("__nvptx_unisimt__");	\
     } while (0)
 
+/* Target CPU versions for D.  */
+#define TARGET_D_CPU_VERSIONS nvptx_d_target_versions
+
 /* Avoid the default in ../../gcc.c, which adds "-pthread", which is not
    supported for nvptx.  */
 #define GOMP_SELF_SPECS ""
--- a/gcc/config/nvptx/t-nvptx
+++ b/gcc/config/nvptx/t-nvptx
@@ -10,3 +10,7 @@ mkoffload$(exeext): mkoffload.o collect-utils.o libcommon-target.a $(LIBIBERTY)
 	  mkoffload.o collect-utils.o libcommon-target.a $(LIBIBERTY) $(LIBS)
 
 MULTILIB_OPTIONS = mgomp
+
+nvptx-d.o: $(srcdir)/config/nvptx/nvptx-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/openbsd-d.c
+++ b/gcc/config/openbsd-d.c
@@ -0,0 +1,49 @@
+/* OpenBSD support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "tm_d.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_OS_VERSIONS for OpenBSD targets.  */
+
+static void
+openbsd_d_os_builtins (void)
+{
+  d_add_builtin_version ("OpenBSD");
+  d_add_builtin_version ("Posix");
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for OpenBSD targets.  */
+
+static unsigned
+openbsd_d_critsec_size (void)
+{
+  /* This is the sizeof pthread_mutex_t, an opaque pointer.  */
+  return POINTER_SIZE_UNITS;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS openbsd_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE openbsd_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/riscv/riscv-d.c
+++ b/gcc/config/riscv/riscv-d.c
@@ -0,0 +1,39 @@
+/* Subroutines for the D front end on the RISC-V architecture.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify
+it under the terms of the GNU General Public License as published by
+the Free Software Foundation; either version 3, or (at your option)
+any later version.
+
+GCC is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+GNU General Public License for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "target.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_CPU_VERSIONS for RISC-V targets.  */
+
+void
+riscv_d_target_versions (void)
+{
+  if (TARGET_64BIT)
+    d_add_builtin_version ("RISCV64");
+  else
+    d_add_builtin_version ("RISCV32");
+
+  if (TARGET_HARDFLOAT)
+    d_add_builtin_version ("D_HardFloat");
+  else
+    d_add_builtin_version ("D_SoftFloat");
+}
--- a/gcc/config/riscv/riscv-protos.h
+++ b/gcc/config/riscv/riscv-protos.h
@@ -74,6 +74,9 @@ extern unsigned int riscv_hard_regno_nregs (int, enum machine_mode);
 /* Routines implemented in riscv-c.c.  */
 void riscv_cpu_cpp_builtins (cpp_reader *);
 
+/* Routines implemented in riscv-d.c  */
+extern void riscv_d_target_versions (void);
+
 /* Routines implemented in riscv-builtins.c.  */
 extern void riscv_atomic_assign_expand_fenv (tree *, tree *, tree *);
 extern rtx riscv_expand_builtin (tree, rtx, rtx, enum machine_mode, int);
--- a/gcc/config/riscv/riscv.h
+++ b/gcc/config/riscv/riscv.h
@@ -27,6 +27,9 @@ along with GCC; see the file COPYING3.  If not see
 /* Target CPU builtins.  */
 #define TARGET_CPU_CPP_BUILTINS() riscv_cpu_cpp_builtins (pfile)
 
+/* Target CPU versions for D.  */
+#define TARGET_D_CPU_VERSIONS riscv_d_target_versions
+
 /* Default target_flags if no switches are specified  */
 
 #ifndef TARGET_DEFAULT
--- a/gcc/config/riscv/t-riscv
+++ b/gcc/config/riscv/t-riscv
@@ -9,3 +9,7 @@ riscv-c.o: $(srcdir)/config/riscv/riscv-c.c $(CONFIG_H) $(SYSTEM_H) \
     coretypes.h $(TM_H) $(TREE_H) output.h $(C_COMMON_H) $(TARGET_H)
 	$(COMPILER) -c $(ALL_COMPILERFLAGS) $(ALL_CPPFLAGS) $(INCLUDES) \
 		$(srcdir)/config/riscv/riscv-c.c
+
+riscv-d.o: $(srcdir)/config/riscv/riscv-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/sol2-d.c
+++ b/gcc/config/sol2-d.c
@@ -0,0 +1,49 @@
+/* Solaris support needed only by D front-end.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+
+GCC is free software; you can redistribute it and/or modify it under
+the terms of the GNU General Public License as published by the Free
+Software Foundation; either version 3, or (at your option) any later
+version.
+
+GCC is distributed in the hope that it will be useful, but WITHOUT ANY
+WARRANTY; without even the implied warranty of MERCHANTABILITY or
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+for more details.
+
+You should have received a copy of the GNU General Public License
+along with GCC; see the file COPYING3.  If not see
+<http://www.gnu.org/licenses/>.  */
+
+#include "config.h"
+#include "system.h"
+#include "coretypes.h"
+#include "tm_d.h"
+#include "d/d-target.h"
+#include "d/d-target-def.h"
+
+/* Implement TARGET_D_OS_VERSIONS for Solaris targets.  */
+
+static void
+solaris_d_os_builtins (void)
+{
+  d_add_builtin_version ("Solaris");
+  d_add_builtin_version ("Posix");
+}
+
+/* Implement TARGET_D_CRITSEC_SIZE for Solaris targets.  */
+
+static unsigned
+solaris_d_critsec_size (void)
+{
+  /* This is the sizeof pthread_mutex_t.  */
+  return 24;
+}
+
+#undef TARGET_D_OS_VERSIONS
+#define TARGET_D_OS_VERSIONS solaris_d_os_builtins
+
+#undef TARGET_D_CRITSEC_SIZE
+#define TARGET_D_CRITSEC_SIZE solaris_d_critsec_size
+
+struct gcc_targetdm targetdm = TARGETDM_INITIALIZER;
--- a/gcc/config/t-darwin
+++ b/gcc/config/t-darwin
@@ -26,6 +26,9 @@ darwin-c.o: $(srcdir)/config/darwin-c.c
 	$(COMPILE) $(PREPROCESSOR_DEFINES) $<
 	$(POSTCOMPILE)
 
+darwin-d.o: $(srcdir)/config/darwin-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
 
 darwin-f.o: $(srcdir)/config/darwin-f.c
 	$(COMPILE) $<
--- a/gcc/config/t-dragonfly
+++ b/gcc/config/t-dragonfly
@@ -0,0 +1,3 @@
+dragonfly-d.o: config/dragonfly-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/t-freebsd
+++ b/gcc/config/t-freebsd
@@ -0,0 +1,3 @@
+freebsd-d.o: config/freebsd-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/t-netbsd
+++ b/gcc/config/t-netbsd
@@ -0,0 +1,3 @@
+netbsd-d.o: config/netbsd-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/t-openbsd
+++ b/gcc/config/t-openbsd
@@ -1,2 +1,6 @@
 # We don't need GCC's own include files.
 USER_H = $(EXTRA_HEADERS)
+
+openbsd-d.o: config/openbsd-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
--- a/gcc/config/t-sol2
+++ b/gcc/config/t-sol2
@@ -26,6 +26,11 @@ sol2-cxx.o: $(srcdir)/config/sol2-cxx.c
 	$(COMPILE) $<
 	$(POSTCOMPILE)
 
+# Solaris-specific D support.
+sol2-d.o: $(srcdir)/config/sol2-d.c
+	$(COMPILE) $<
+	$(POSTCOMPILE)
+
 # Corresponding stub routines.
 sol2-stubs.o: $(srcdir)/config/sol2-stubs.c
 	$(COMPILE) $<
