# The name of your project (used to name the compiled .hex file)
#TARGET = main

#
# Various directories
#
ARDUINO = C:\devt\arduino\arduino-1.0.5
TOOLS_PATH = $(ARDUINO)\hardware\tools
COMPILER_PATH = $(TOOLS_PATH)\arm-none-eabi\bin
CORE_PATH = $(ARDUINO)\hardware\teensy\cores/teensy3
CORE_PATH2 := $(subst \,/,$(CORE_PATH))
BUILD = ./build

ECHO = @echo

#
# ARM compiler toolchain...
#
AS = $(COMPILER_PATH)\arm-none-eabi-as
CC = $(COMPILER_PATH)\arm-none-eabi-gcc
CXX = $(COMPILER_PATH)\arm-none-eabi-g++
LD = $(COMPILER_PATH)\arm-none-eabi-ld
OBJCOPY = $(COMPILER_PATH)\arm-none-eabi-objcopy
SIZE = $(COMPILER_PATH)\arm-none-eabi-size

#
# Sources for this project...
#
SRC_C = 
	
SRC_CPP  = \
	main.cpp
	
SRC_OBJS := $(SRC_C:.c=.o) $(SRC_CPP:.cpp=.o)

#
# NOTE: MUST use unix slashes for wildcard macro
#

TEENSY_C_FILES := $(filter-out %/main.c,$(wildcard $(CORE_PATH)/*.c))
TEENSY_C_FILES := $(subst \,/,$(TEENSY_C_FILES))
TEENSY_CPP_FILES := $(filter-out %/main.cpp,$(wildcard $(CORE_PATH)/*.cpp))
TEENSY_CPP_FILES := $(subst \,/,$(TEENSY_CPP_FILES))
TEENSY_OBJS := $(TEENSY_C_FILES:.c=.c.o) $(TEENSY_CPP_FILES:.cpp=.cpp.o)
TEENSY_OBJS := $(patsubst $(CORE_PATH2)%,$(BUILD)/teensy%,$(TEENSY_OBJS))

OBJS := $(addprefix $(BUILD)/, $(SRC_OBJS)) $(TEENSY_OBJS)

#
# configurable options
#
OPTIONS = -DF_CPU=96000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -D__MK20DX256__ -DTEENSYDUINO=117 -DUSB_VID=null -DUSB_PID=null -DARDUINO=105 

#
# CPPFLAGS = compiler options for C and C++
#
CPPFLAGS = -Wall -g -Os -mcpu=cortex-m4 -mthumb -nostdlib -MMD $(OPTIONS) -I. -I$(CORE_PATH)

# compiler options for C++ only
# -fno-exceptions -ffunction-sections -fdata-sections
CXXFLAGS = -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti

# -std=gnu99

# compiler options for C only
CFLAGS =

# CFLAGS = -I. -I$(PY_SRC) -I$(CORE_PATH) -Wall -ansi 
# CFLAGS = -I. -I$(CORE_PATH) -Wall -ansi -std=gnu99
# LIBS = -lgcc

# linker options
LDFLAGS = -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -T$(CORE_PATH)\mk20dx256.ld

# additional libraries to link
LIBS = -lm


#all: $(BUILD)/teensy $(BUILD)/main.hex 

all: $(BUILD)/teensy $(BUILD)/main.hex upload

$(BUILD)/main.hex : $(BUILD)/main.elf

$(BUILD)/main.elf: $(OBJS)
	$(ECHO) "LINK $@"
	$(Q)$(CC) $(LDFLAGS) -o "$@" -Wl,-Map,$(@:.elf=.map) $(OBJS) $(LIBS)
	$(Q)$(SIZE) $@

#
# .c to .o inference rule
#
$(BUILD)/%.o: %.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

#
# .cpp to .o inference rule
#
$(BUILD)/%.o: %.cpp
	$(ECHO) "CC $<"
	$(Q)$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<


#
# .c to .o inference rule
#
$(BUILD)/teensy/%.c.o : $(CORE_PATH)\%.c 
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

#
# .c to .o inference rule
#
$(BUILD)/teensy/%.cpp.o : $(CORE_PATH)\%.cpp
	$(ECHO) "CXX $<"
	$(Q)$(CC) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<


#
# .elf to .hex inference rule (note, needs both to be added to .SUFFIXES)
#
%.hex: %.elf
	$(ECHO) "HEX $<"
	$(OBJCOPY) -O ihex -R .eeprom "$<" "$@"

post_compile: $(BUILD)/main.hex
	$(ECHO) "Preparing $@ for upload"
	$(TOOLS_PATH)/teensy_post_compile -board=teensy31 -tools="$(TOOLS_PATH)" -path="$(realpath $(BUILD))" -file="$(basename $(<F))"

reboot:
	$(ECHO) "REBOOT"
	-$(TOOLS_PATH)/teensy_reboot

upload: post_compile reboot


test: 
	$(ECHO) "TEST"
	$(ECHO) $(ARDUINO)
	$(ECHO) $(OBJS)

test2: 
	$(ECHO) $(TEENSY_C_FILES)
	$(ECHO) $(TEENSY_CPP_FILES)

$(BUILD):
	-mkdir $(subst /,\,$(BUILD))

$(BUILD)/teensy: $(BUILD)
	-mkdir $(subst /,\,$(BUILD))\teensy

clean:
	-rd /q /s $(subst /,\,$(BUILD))

#.PHONY: all all2 clean