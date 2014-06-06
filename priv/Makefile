# Dumb, brute-force Makefile....

# Driver name, without the "_drv" suffix
DRIVER_NAME = unixdom

# Path to erl_driver.h
DRIVER_H_DIR = $(ERL_HOME)/lib/erlang/usr/include

# Path to EDTK files (all of the final products, currently in one happy dir)
EDTK_DIR ?= ../../edtk

#EXTERNAL_CFLAGS = -I/user/fritchie/src/e-d/edtk/examples/3rd-party-files
#EXTERNAL_SHARED_OBJS = /user/fritchie/src/e-d/edtk/examples/3rd-party-files/libgd.so

CC = gcc
ERLC = erlc
GSLGEN = env EDTK_DIR=$(EDTK_DIR) gslgen

# If you run "erl" and see this: 
#       Erlang (BEAM) emulator version 5.1.1 [source] 
# ... then you have a thread-unaware VM.  However, if you see:
#       Erlang (BEAM) emulator version 5.1.1 [source] [threads:0]
# then you've got a thread-aware VM, so you'd better uncomment the 
# following line.
PTHREAD_DEFS = -DDRIVER_USING_PTHREADS -D_THREAD_SAFE -D_REENTRANT

#
# You probably don't change anything below this point.
#

INCLS = -I$(DRIVER_H_DIR) -I.
CFLAGS  = -g $(INCLS) -Wall -pedantic $(PTHREAD_DEFS) \
        -I$(EDTK_DIR) $(EXTERNAL_CFLAGS)
ERL_FLAGS = +debug_info

SUFFIX = 
LIBS = $(DRIVER_NAME)$(SUFFIX).so
BEAMS = $(DRIVER_NAME)$(SUFFIX).beam $(DRIVER_NAME)_test.beam
OBJS = $(EDTK_DIR)/erl_driver_tk.o $(EDTK_DIR)/erl_driver_pipelib.o \
	$(DRIVER_NAME)$(SUFFIX).o my-$(DRIVER_NAME).o \
	$(EXTERNAL_SHARED_OBJS)


.SUFFIXES: .jam .beam .erl .so .c

.c.o:
	$(CC) $(CFLAGS) -fPIC -c -o $@ $<

.erl.beam:
	$(ERLC) -bbeam $(ERL_FLAGS) $(ERL_COMPILE_FLAGS) -o $@ $<

GENERATED_FILES = ../src/$(DRIVER_NAME)$(SUFFIX).erl ../src/$(DRIVER_NAME)$(SUFFIX).hrl \
                  ../c_src/$(DRIVER_NAME)$(SUFFIX).h ../c_src/$(DRIVER_NAME)$(SUFFIX).c

all: $(GENERATED_FILES) $(LIBS) $(BEAMS)

../src/$(DRIVER_NAME)$(SUFFIX).erl: $(DRIVER_NAME).xml $(EDTK_DIR)/erl_template.gsl ../src/$(DRIVER_NAME)$(SUFFIX).hrl
	-mv ../c_src/$(DRIVER_NAME)$(SUFFIX).erl $(DRIVER_NAME)$(SUFFIX).erl.`date +%s`
	$(GSLGEN) -script:$(EDTK_DIR)/erl_template.gsl $(DRIVER_NAME).xml > $@

../src/$(DRIVER_NAME)$(SUFFIX).hrl: $(DRIVER_NAME).xml $(EDTK_DIR)/hrl_template.gsl
	-mv ../src/$(DRIVER_NAME)$(SUFFIX).hrl $(DRIVER_NAME)$(SUFFIX).hrl.`date +%s`
	$(GSLGEN) -script:$(EDTK_DIR)/hrl_template.gsl $(DRIVER_NAME).xml > $@

../c_src/$(DRIVER_NAME)$(SUFFIX).h: $(DRIVER_NAME).xml $(EDTK_DIR)/c_h_template.gsl
	-mv ../c_src/$(DRIVER_NAME)$(SUFFIX).h $(DRIVER_NAME)$(SUFFIX).h.`date +%s`
	$(GSLGEN) -script:$(EDTK_DIR)/c_h_template.gsl $(DRIVER_NAME).xml > $@

../c_src/$(DRIVER_NAME)$(SUFFIX).c: $(DRIVER_NAME).xml $(EDTK_DIR)/c_c_template.gsl ../c_src/$(DRIVER_NAME)$(SUFFIX).h
	-mv ../c_src/$(DRIVER_NAME)$(SUFFIX).c $(DRIVER_NAME)$(SUFFIX).c.`date +%s`
	$(GSLGEN) -script:$(EDTK_DIR)/c_c_template.gsl $(DRIVER_NAME).xml > $@

my-$(DRIVER_NAME).o: my-$(DRIVER_NAME).c my-$(DRIVER_NAME).h

$(DRIVER_NAME)$(SUFFIX).so: $(OBJS)
	$(CC) -shared $(OBJS) -o $(DRIVER_NAME)$(SUFFIX).so

../ebin/$(DRIVER_NAME)$(SUFFIX).beam: ../src/$(DRIVER_NAME)$(SUFFIX).erl

regression: all
	erl +A5 -pz $(EDTK_DIR) -s $(DRIVER_NAME)_test regression -s erlang halt

clean:
	find .. -type f -print | \
	egrep '\.102|\.o$$|\.so$$|\.beam$$|/core$$|\.core$$|erl_crash.dump|ktrace.out|FOO.*-testfile' | xargs rm
	rm -f TEST?

distclean: clean
	@echo ""
	@echo "If you __really__ want to do that, manually run this command:"
	@echo ""
	@echo "	rm $(GENERATED_FILES)"
	@echo ""
	@echo "WARNING: if you've made manual edits to any of those files,"
	@echo "do not casually delete them!!"
	@echo ""

