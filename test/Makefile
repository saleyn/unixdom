ERLC_INC_DIRS += ../src
EBIN_DIR       = ../ebin
include $(ERL_HOME)/common/include.mk
include $(ERL_HOME)/common/targets.mk

ifeq (test, $(notdir $(PWD)))
  LOC := test
else
  LOC := other
endif

t:
	echo $(notdir $(PWD))
	echo $(LOC)

# Some modules are automatically generated, so we won't use the
# include makefile's auto-detected list.
#MODULES := unixdom_test
#OBJECTS := $(MODULES:%=../ebin/%.$(EMULATOR))

#ERLC_FLAGS += -I../src

#all: $(OBJECTS)

#clean:
#	rm -f $(OBJECTS)

#test: all
#	erl +A5 -pz ../ebin -pz ../priv -s unixdom_test regression -s erlang halt

