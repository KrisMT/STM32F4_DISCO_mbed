#
# File: Makefile for all mbed supported platforms (ARM GCC)
#
# Copyright (c) 10.2013, 0xc0170
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Support STM32F429I-DISCOVERY
include Platforms

# path to the mbed library
MBED_DIR = mbed

# toolchain specific
TOOLCHAIN = arm-none-eabi-
CC = $(TOOLCHAIN)gcc
CXX = $(TOOLCHAIN)g++
AS = $(TOOLCHAIN)gcc -x assembler-with-cpp
LD = $(TOOLCHAIN)gcc
OBJCP = $(TOOLCHAIN)objcopy
AR = $(TOOLCHAIN)ar

# application specific
INSTRUCTION_MODE = thumb
TARGET = mbed
TARGET_EXT = elf
LD_SCRIPT = $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/$(LINKER_NAME).ld

CC_SYMBOLS = -D$(TARGET_BOARD) -DTOOLCHAIN_GCC_ARM -DNDEBUG

LIB_DIRS = $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM
LIBS = -lmbed -lstdc++ -lsupc++ -lm -lgcc -lc -lnosys

MBED_OBJ = $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/board.o
MBED_OBJ += $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/cmsis_nvic.o
MBED_OBJ += $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/$(STARTUP_NAME).o
MBED_OBJ += $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/retarget.o
MBED_OBJ += $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/$(SYSTEM_NAME).o
ifneq ("$(wildcard $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/mbed_overrides.o)","")
	MBED_OBJ += $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM/mbed_overrides.o
endif

# directories
INC_DIRS = $(MBED_DIR) $(MBED_DIR)/$(TARGET_BOARD) $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM
INC_DIRS += $(MBED_DIR)/$(TARGET_BOARD)/$(TARGET_VENDOR)/$(TARGET_FAMILY)
INC_DIRS += $(MBED_DIR)/$(TARGET_BOARD)/$(TARGET_VENDOR)/$(TARGET_FAMILY)/$(TARGET_SPECIFIC)
# app headers directories (remove comment and add more files)
#INC_DIRS +=

SRC_DIRS = $(MBED_DIR) $(MBED_DIR)/$(TARGET_BOARD) $(MBED_DIR)/$(TARGET_BOARD)/TOOLCHAIN_GCC_ARM .
SRC_DIRS += $(MBED_DIR)/$(TARGET_BOARD)/$(TARGET_VENDOR)/$(TARGET_FAMILY)
SRC_DIRS += $(MBED_DIR)/$(TARGET_BOARD)/$(TARGET_VENDOR)/$(TARGET_FAMILY)/$(TARGET_SPECIFIC)
# app source directories (remove comment and add more files)
SRC_DIRS += SRC

OUT_DIR = build

INC_DIRS_F = -I. $(patsubst %, -I%, $(INC_DIRS))

ifeq ($(strip $(OUT_DIR)), )
	OBJ_FOLDER =
else
	OBJ_FOLDER = $(strip $(OUT_DIR))/
endif

COMPILER_OPTIONS  = -g -ggdb -Os -Wall -fno-strict-aliasing -fno-rtti
COMPILER_OPTIONS += -ffunction-sections -fdata-sections -fno-exceptions -fno-delete-null-pointer-checks
COMPILER_OPTIONS += -fmessage-length=0 -fno-builtin -m$(INSTRUCTION_MODE)
COMPILER_OPTIONS += -mcpu=$(CPU) -MMD -MP $(CC_SYMBOLS)

DEPEND_OPTS = -MF $(OBJ_FOLDER)$(@F:.o=.d)

# Flags
CFLAGS = $(COMPILER_OPTIONS) $(DEPEND_OPTS) $(INC_DIRS_F) -std=gnu99 -c

CXXFLAGS = $(COMPILER_OPTIONS) $(DEPEND_OPTS) $(INC_DIRS_F) -std=gnu++98 -c

ASFLAGS = $(COMPILER_OPTIONS) $(INC_DIRS_F) -c

# Linker options
LD_OPTIONS = -mcpu=$(CPU) -m$(INSTRUCTION_MODE) -Os -L $(LIB_DIRS) -T $(LD_SCRIPT) $(INC_DIRS_F)
LD_OPTIONS += -specs=nano.specs
#use this if %f is used, by default it's commented
#LD_OPTIONS += -u _printf_float -u _scanf_float
LD_OPTIONS += -Wl,-Map=$(OBJ_FOLDER)$(TARGET).map,--gc-sections

OBJCPFLAGS = -O ihex

ARFLAGS = cr

RM = rm -rf

DUP_OBJS = $(LIB_DIRS)/board.o $(LIB_DIRS)/cmsis_nvic.o $(LIB_DIRS)/$(STARTUP_NAME).o $(LIB_DIRS)/retarget.o $(LIB_DIRS)/$(SYSTEM_NAME).o $(LIB_DIRS)/mbed_overrides.o
USER_DIRS = $(foreach dir,$(LIB_DIRS),$(wildcard $(dir)/*.o))
STM_OBJS = $(filter-out $(DUP_OBJS),$(USER_DIRS))
USER_OBJS = $(patsubst %.o,$(LIB_DIRS)/%.o,$(notdir $(STM_OBJS)))
C_SRCS =
S_SRCS =
C_OBJS =
S_OBJS =

# All source/object files inside SRC_DIRS
C_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
C_OBJS := $(patsubst %.c,$(OBJ_FOLDER)%.o,$(notdir $(C_SRCS)))

CPP_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.cpp))
CPP_OBJS := $(patsubst %.cpp,$(OBJ_FOLDER)%.o,$(notdir $(CPP_SRCS)))

S_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.s))
S_OBJS := $(patsubst %.s,$(OBJ_FOLDER)%.o,$(notdir $(S_SRCS)))

VPATH := $(SRC_DIRS)

$(OBJ_FOLDER)%.o : %.c
	@echo 'Building file: $(@F)'
	@echo 'Invoking: MCU C Compiler'
	$(CC) $(CFLAGS) $< -o $@
	@echo 'Finished building: $(@F)'
	@echo ' '

$(OBJ_FOLDER)%.o : %.cpp
	@echo 'Building file: $(@F)'
	@echo 'Invoking: MCU C++ Compiler'
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo 'Finished building: $(@F)'
	@echo ' '

$(OBJ_FOLDER)%.o : %.s
	@echo 'Building file: $(@F)'
	@echo 'Invoking: MCU Assembler'
	$(AS) $(ASFLAGS) $< -o $@
	@echo 'Finished building: $(@F)'
	@echo ' '

all: create_outputdir $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) print_info

create_outputdir:
	$(shell mkdir $(OBJ_FOLDER) 2>/dev/null)

# Tool invocations
$(OBJ_FOLDER)$(TARGET).$(TARGET_EXT): $(LD_SCRIPT) $(C_OBJS) $(CPP_OBJS) $(S_OBJS) $(MBED_OBJ) $(USER_OBJS) 
	@echo 'Building target: $@'
	@echo 'Invoking: MCU Linker'
	$(LD) $(LD_OPTIONS) $(CPP_OBJS) $(C_OBJS) $(S_OBJS) $(MBED_OBJ) $(USER_OBJS) $(LIBS)  -o $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT)
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	@echo 'Removing entire out directory'
	$(RM) $(TARGET).$(TARGET_EXT) $(TARGET).bin $(TARGET).map $(OBJ_FOLDER)*.* $(OBJ_FOLDER)
	@echo ' '

print_info:
	@echo 'Printing size'
	arm-none-eabi-size --totals $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT)
	arm-none-eabi-objcopy -O srec $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) $(OBJ_FOLDER)$(TARGET).s19
	arm-none-eabi-objcopy -O binary -v $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) $(OBJ_FOLDER)$(TARGET).bin
	arm-none-eabi-objdump -D $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) > $(OBJ_FOLDER)$(TARGET).lst
	arm-none-eabi-nm $(OBJ_FOLDER)$(TARGET).$(TARGET_EXT) > $(OBJ_FOLDER)$(TARGET)-symbol-table.txt
	@echo ' '

flash:
	st-flash write $(OBJ_FOLDER)/$(TARGET).bin 0x08000000

.PHONY: all clean print_info flash
