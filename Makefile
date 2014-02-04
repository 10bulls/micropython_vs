# The name of your project (used to name the compiled .hex file)
#TARGET = main
all: all2
BUILD_VERBOSE = 1

#
# Various directories
#
ARDUINO = C:\devt\arduino\arduino-1.0.5
TOOLS_PATH = $(ARDUINO)\hardware\tools
COMPILER_PATH = $(TOOLS_PATH)\arm-none-eabi\bin
CORE_PATH = $(ARDUINO)\hardware\teensy\cores/teensy3
CORE_PATH2 := $(subst \,/,$(CORE_PATH))
BUILD = ./build
PYTHON = C:\Python27\python

PY_ROOT = C:/devt/arduino/micropython
PY_SRC = $(PY_ROOT)/py
PY_BUILD = $(BUILD)/py

STM_SRC = $(PY_ROOT)/stm
MPTEENSY_SRC = $(PY_ROOT)/teensy

QSTR_DEFS = $(STM_SRC)/qstrdefsport.h

#
# includes
#
include util.mk
include py.mk

ECHO = @echo

#
# ARM compiler toolchain...
#
AS = $(COMPILER_PATH)\arm-none-eabi-as
AR = $(COMPILER_PATH)/arm-none-eabi-ar
CC = $(COMPILER_PATH)\arm-none-eabi-gcc
CXX = $(COMPILER_PATH)\arm-none-eabi-g++
LD = $(COMPILER_PATH)\arm-none-eabi-ld
RANLIB = $(COMPILER_PATH)/arm-none-eabi-ranlib
OBJCOPY = $(COMPILER_PATH)\arm-none-eabi-objcopy
SIZE = $(COMPILER_PATH)\arm-none-eabi-size

#
# Sources for this project...
#

SRC_CPP  = \
	main.cpp \
	myPrint.cpp \

SRC_C = \
	pymain.c
	
SRC_OBJS := $(SRC_C:.c=.o) $(SRC_CPP:.cpp=.o)

#
# Micropython source files...
#
#	main.c 
#
MPTEENSY_SRC_C = \
	lcd.c \
	led.c \
	lexerfatfs.c \
	lexermemzip.c \
	memzip.c \
	usart.c \
	usb.c \

#	servo.c \


STM_SRC_C = \
	malloc0.c \
	ap_printf.c \
	string0.c \

#	printf.c \


STM_SRC_S = \
	gchelper.s \

MP_OBJS = $(addprefix $(BUILD)/, $(MPTEENSY_SRC_C:.c=.c.o) $(STM_SRC_C:.c=.c.o) $(STM_SRC_S:.s=.s.o))


# Use these rather than including everything in teensy
TEENSY_C = \
	analog.c \
	mk20dx128.c \
	pins_teensy.c \
	serial3.c \
	usb_desc.c \
	usb_dev.c \
	usb_mem.c \
	usb_serial.c \
	yield.c \

#	nonstd.c \

TEENSY_C_FILES = $(addprefix $(CORE_PATH)/, $(TEENSY_C))

TEENSY_CPP = \
	usb_inst.cpp \
	Stream.cpp \
	WString.cpp \
	HardwareSerial3.cpp \

TEENSY_CPP_FILES = $(addprefix $(CORE_PATH)/, $(TEENSY_CPP))

# TODO: need vdprintf etc to get this working...
#	Print.cpp \


#
# NOTE: MUST use unix slashes for wildcard macro
#

#TEENSY_C_FILES := $(filter-out %/main.c,$(wildcard $(CORE_PATH)/*.c))
TEENSY_C_FILES := $(subst \,/,$(TEENSY_C_FILES))

#TEENSY_CPP_FILES := $(filter-out %/main.cpp,$(wildcard $(CORE_PATH)/*.cpp))
TEENSY_CPP_FILES := $(subst \,/,$(TEENSY_CPP_FILES))

TEENSY_OBJS := $(TEENSY_C_FILES:.c=.c.o) $(TEENSY_CPP_FILES:.cpp=.cpp.o)
TEENSY_OBJS := $(patsubst $(CORE_PATH2)%,$(BUILD)/teensy%,$(TEENSY_OBJS))


ARDUINOLIB_CPP = \
	QTRSensors.cpp \

ARDUINOLIB_O := $(addprefix $(BUILD)/, $(ARDUINOLIB_CPP:.cpp=.cpp.o))

ARDUINOLIB_CPP := $(addprefix libraries/, $(ARDUINOLIB_CPP))

OBJS := $(addprefix $(BUILD)/, $(SRC_OBJS)) $(MP_OBJS) $(TEENSY_OBJS) $(PY_O) $(ARDUINOLIB_O)

LIB_OBJS := $(MP_OBJS) $(PY_O) 
LIB_OBJS := $(filter-out %/main.o %/main.cpp.o %/pymain.o %/string0.c.o , $(LIB_OBJS))

# The following rule uses | to create an order only prereuisite. Order only
# prerequisites only get built if they don't exist. They don't cause timestamp
# checkng to be performed.
#
# $(sort $(var)) removes duplicates
#
# The net effect of this, is it causes the objects to depend on the
# object directories (but only for existance), and the object directories
# will be created if they don't exist.
OBJ_DIRS = $(sort $(dir $(OBJS)))
$(OBJS): | $(OBJ_DIRS)
$(OBJ_DIRS):
	-mkdir $(subst /,\,$@)


#
# configurable options
#
OPTIONS = -DF_CPU=96000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -D__MK20DX256__ -DTEENSYDUINO=117 -DUSB_VID=null -DUSB_PID=null -DARDUINO=105 

#
# CPPFLAGS = compiler options for C and C++
#
# CPPFLAGS = -Wall -g -Os -mcpu=cortex-m4 -mthumb -nostdlib -MMD $(OPTIONS) -I. -I $(MPTEENSY_SRC) -I $(PY_SRC) -I $(STM_SRC) -I$(CORE_PATH) -Ilibraries
CPPFLAGS = -Wall -g -Os -mcpu=cortex-m4 -mthumb -nodefaultlibs -MMD $(OPTIONS) -I. -I $(MPTEENSY_SRC) -I $(PY_SRC) -I $(STM_SRC) -I$(CORE_PATH) -Ilibraries

# compiler options for C++ only
# -fno-exceptions -ffunction-sections -fdata-sections
CXXFLAGS = -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti

# compiler options for C only
CFLAGS = -std=gnu99

# CFLAGS = -I. -I$(PY_SRC) -I$(CORE_PATH) -Wall -ansi 
# CFLAGS = -I. -I$(CORE_PATH) -Wall -ansi -std=gnu99
# LIBS = -lgcc

# linker options
# LDFLAGS = -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -T$(CORE_PATH)\mk20dx256.ld
# LDFLAGS = -nostdlib -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -T$(CORE_PATH)\mk20dx256py.ld
LDFLAGS = -nodefaultlibs -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -T$(CORE_PATH)\mk20dx256py.ld

# additional libraries to link
# LIBS = -lm
# LIBS = -lgcc -lm

# LIBS = -lm -mthumb -L"C:\devt\arduino\arduino-1.0.5\hardware\tools\arm-none-eabi\arm-none-eabi\lib" -L"C:\devt\arduino\arduino-1.0.5\hardware\tools\arm-none-eabi\lib\gcc\arm-none-eabi\4.7.2\thumb2" -lgcc 
LIBS = -lm -lgcc -mthumb 

#all: $(BUILD)/teensy $(BUILD)/main.hex 

# all2: $(BUILD)/teensy $(BUILD)/main.hex upload

all2: $(BUILD)/teensy $(BUILD)/libmpython.a $(BUILD)/main-mz.hex upload

$(BUILD)/libmpython.a: $(LIB_OBJS)
	$(Q)$(AR) rcu "$@" $(LIB_OBJS) 
	$(Q)$(RANLIB) $@


$(BUILD)/main.hex : $(BUILD)/main.elf

$(BUILD)/main.elf: $(OBJS)
	$(ECHO) "LINK $@"
	$(Q)$(CC) $(LDFLAGS) -o "$@" $(OBJS) $(LIBS)
	$(Q)$(SIZE) $@

#	$(Q)$(CC) $(LDFLAGS) -o "$@" -Wl,-Map,$(@:.elf=.map) $(OBJS) $(LIBS)


$(BUILD)/pymain.o: $(PY_BUILD)/qstrdefs.generated.h

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


$(BUILD)/%.c.o: $(MPTEENSY_SRC)/%.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.s.o: $(STM_SRC)/%.s
	$(ECHO) "AS $<"
	$(Q)$(AS) -o $@ $<

$(BUILD)/%.c.o: $(STM_SRC)/%.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

#
# .c to .o inference rule
#
$(BUILD)/teensy/%.c.o : $(CORE_PATH)\%.c 
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<


#
# .c to .o inference rule
#
$(BUILD)/%.cpp.o : libraries/%.cpp
	$(ECHO) "CXX $<"
	$(Q)$(CC) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<


#
# .c to .o inference rule
#
$(BUILD)/teensy/%.cpp.o : $(CORE_PATH)\%.cpp
	$(ECHO) "CXX $<"
	$(Q)$(CC) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

ifeq ($(MEMZIP_DIR),)
MEMZIP_DIR = memzip_files
endif

$(BUILD)/main-mz.hex: $(BUILD)/main.hex $(shell find ${MEMZIP_DIR} -type f)
	@$(ECHO) "Creating $@"
	$(Q).\add-memzip.bat $(subst /,\,$(abspath $<)) $(subst /,\,$@) $(subst /,\,${MEMZIP_DIR})

#
# .elf to .hex inference rule 
#
%.hex: %.elf
	$(ECHO) "HEX $<"
	$(OBJCOPY) -O ihex -R .eeprom "$<" "$@"

post_compile: $(BUILD)/main-mz.hex
	$(ECHO) "Preparing $@ for upload"
	$(TOOLS_PATH)/teensy_post_compile -board=teensy31 -tools="$(TOOLS_PATH)" -path="$(realpath $(BUILD))" -file="$(basename $(<F))"

reboot:
	$(ECHO) "REBOOT"
	-$(TOOLS_PATH)/teensy_reboot

upload: post_compile reboot


test: 
	$(ECHO) "TEST"
	$(ECHO) $(LIB_OBJS)
#	$(ECHO) $(ARDUINO)
#	$(ECHO) $(OBJS)

test2: 
	$(ECHO) $(TEENSY_C_FILES)
	$(ECHO) $(TEENSY_CPP_FILES)

$(BUILD):
	-mkdir $(subst /,\,$(BUILD))

$(BUILD)/teensy: $(BUILD)
	-mkdir $(subst /,\,$(BUILD))\teensy

$(BUILD)/py: $(BUILD)
	-mkdir $(subst /,\,$(BUILD))\py

$(BUILD)/py/: $(BUILD)
	-mkdir $(subst /,\,$(BUILD))\py

clean:
	-rd /q /s $(subst /,\,$(BUILD))

.PHONY: all all2 clean

