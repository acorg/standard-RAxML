# -*- Makefile -*-
# Makefile August 2006 by Alexandros Stamatakis
# Makefile cleanup October 2006, Courtesy of Peter Cordes <peter@cordes.ca>
# Combined makefile 2019-04-06 by Eugene Skepner

OPENMP = NO
PTHREADS = NO
AVX = YES

$(info $(HOST) $(HOSTNAME))

# ----------------------------------------------------------------------

ifneq (,$(findstring darwin,$(MAKE_HOST)))
  CC = /usr/local/opt/llvm/bin/clang
  WARNINGS = -Weverything -Wno-padded -Wno-reserved-id-macro -Wno-unused-macros
  OPENMP_CFLAGS = -fopenmp
  OPENMP_LIBS = -lomp
  # -Wall -pedantic -Wunused-parameter -Wredundant-decls  -Wreturn-type  -Wswitch-default -Wunused-value -Wimplicit  -Wimplicit-function-declaration  -Wimplicit-int -Wimport  -Wunused  -Wunused-function  -Wunused-label -Wno-int-to-pointer-cast -Wbad-function-cast  -Wmissing-declarations -Wmissing-prototypes  -Wnested-externs  -Wold-style-definition -Wstrict-prototypes  -Wdeclaration-after-statement -Wpointer-sign -Wextra -Wredundant-decls -Wunused -Wunused-function -Wunused-parameter -Wunused-value  -Wunused-variable -Wformat  -Wformat-nonliteral -Wparentheses -Wsequence-point -Wuninitialized -Wundef -Wbad-function-cast
else ifeq (x86_64-pc-linux-gnu,$(MAKE_HOST))
  CC = gcc-8
  WARNINGS = -Wall -Wno-reserved-id-macro -Wno-unused-macros
  OPENMP_CFLAGS = -fopenmp
  OPENMP_LIBS = -fopenmp
  # -Wall -pedantic -Wunused-parameter -Wredundant-decls  -Wreturn-type  -Wswitch-default -Wunused-value -Wimplicit  -Wimplicit-function-declaration  -Wimplicit-int -Wimport  -Wunused  -Wunused-function  -Wunused-label -Wno-int-to-pointer-cast -Wbad-function-cast  -Wmissing-declarations -Wmissing-prototypes  -Wnested-externs  -Wold-style-definition -Wstrict-prototypes  -Wdeclaration-after-statement -Wpointer-sign -Wextra -Wredundant-decls -Wunused -Wunused-function -Wunused-parameter -Wunused-value  -Wunused-variable -Wformat  -Wformat-nonliteral -Wparentheses -Wsequence-point -Wuninitialized -Wundef -Wbad-function-cast
else
  $(error Unsupported platform $(MAKE_HOST))
endif

CFLAGS = -O3 -mtune=intel -D__SIM_SSE3 -D_GNU_SOURCE -fomit-frame-pointer -funroll-loops $(WARNINGS)
LIBRARIES = -lm
PROG := raxml-$(shell echo $${HOSTNAME})

ifeq ($(AVX),YES)
  CFLAGS += -D__AVX -mavx
  PROG := $(PROG)-avx
else
  CFLAGS += -msse3
endif

ifeq ($(PTHREADS),YES)
  CFLAGS += -D_USE_PTHREADS
  LIBRARIES += -pthread 
  PROG := $(PROG)-pthreads
endif

ifeq ($(OPENMP),YES)
  CFLAGS += $(OPENMP_CFLAGS)
  LIBRARIES += $(OPENMP_LIBS)
  LIBRARIES += -lomp
  PROG := $(PROG)-omp
endif

$(info PROG=$(PROG))
$(error)

objs = \
  axml.o \
  optimizeModel.o \
  multiple.o \
  searchAlgo.o \
  topologies.o \
  parsePartitions.o \
  treeIO.o \
  models.o \
  bipartitionList.o \
  rapidBootstrap.o \
  evaluatePartialGenericSpecial.o \
  evaluateGenericSpecial.o \
  newviewGenericSpecial.o \
  makenewzGenericSpecial.o \
  classify.o \
  fastDNAparsimony.o \
  fastSearch.o \
  leaveDropping.o \
  rmqs.o \
  rogueEPA.o \
  ancestralStates.o \
  avxLikelihood.o \
  mem_alloc.o \
  eigen.o

all : $(PROG)

GLOBAL_DEPS = axml.h globalVariables.h rmq.h rmqs.h #mem_alloc.h

$(PROG) : $(objs)
	$(CC) -o $@ $^ $(LIBRARIES)

avxLikelihood.o : avxLikelihood.c $(GLOBAL_DEPS)
fastDNAparsimony.o : fastDNAparsimony.c $(GLOBAL_DEPS)
rmqs.o : rmqs.c $(GLOBAL_DEPS)
classify.o : classify.c $(GLOBAL_DEPS)
evaluatePartialSpecialGeneric.o : evaluatePartialSpecialGeneric.c $(GLOBAL_DEPS)
bipartitionList.o : bipartitionList.c $(GLOBAL_DEPS)
optimizeModel.o : optimizeModel.c $(GLOBAL_DEPS)
multiple.o : multiple.c $(GLOBAL_DEPS)
axml.o : axml.c $(GLOBAL_DEPS)
searchAlgo.o : searchAlgo.c $(GLOBAL_DEPS)
topologies.o : topologies.c $(GLOBAL_DEPS)
parsePartitions.o : parsePartitions.c $(GLOBAL_DEPS)
treeIO.o : treeIO.c $(GLOBAL_DEPS)
models.o : models.c $(GLOBAL_DEPS)
rapidBootstrap.o : rapidBootstrap.c $(GLOBAL_DEPS)
evaluatePartialGenericSpecial.o : evaluatePartialGenericSpecial.c $(GLOBAL_DEPS)
evaluateGenericSpecial.o : evaluateGenericSpecial.c $(GLOBAL_DEPS)
newviewGenericSpecial.o : newviewGenericSpecial.c $(GLOBAL_DEPS)
makenewzGenericSpecial.o : makenewzGenericSpecial.c $(GLOBAL_DEPS)
fastSearch.o : fastSearch.c $(GLOBAL_DEPS)
leaveDropping.o : leaveDropping.c $(GLOBAL_DEPS)
rogueEPA.o : rogueEPA.c $(GLOBAL_DEPS)
ancestralStates.o : ancestralStates.c $(GLOBAL_DEPS)
mem_alloc.o eigen.o  : mem_alloc.c  $(GLOBAL_DEPS)
eigen.o: eigen.c $(GLOBAL_DEPS)

clean:
	rm -f *.o 

cleanall: clean
	rm -f raxml-*

dev: $(PROG)
