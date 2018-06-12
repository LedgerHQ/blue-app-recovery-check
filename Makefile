#*******************************************************************************
#   Ledger Blue
#   (c) 2016 Ledger
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#*******************************************************************************

ifeq ($(BOLOS_SDK),)
$(error BOLOS_SDK is not set)
endif
include $(BOLOS_SDK)/Makefile.defines

# Main app configuration

APPNAME = "Recovery check"
APPVERSION = 1.0.0
ICONNAME = icon.gif
APP_LOAD_PARAMS = --appFlags 0x10 $(COMMON_LOAD_PARAMS) --apdu --curve secp256k1 --path ""

# Build configuration

APP_SOURCE_PATH += src src_common
SDK_SOURCE_PATH += lib_stusb lib_stusb_impl

DEFINES += APPVERSION=\"$(APPVERSION)\"

DEFINES += OS_IO_SEPROXYHAL IO_SEPROXYHAL_BUFFER_SIZE_B=128
DEFINES += HAVE_BAGL HAVE_SPRINTF
#DEFINES += PRINTF\(...\)=
DEFINES   += HAVE_PRINTF PRINTF=screen_printf
DEFINES   += BOLOS_APP_ICON_SIZE_B=\(9+32\)
DEFINES   += CX_COMPLIANCE_141
DEFINES   += HAVE_ELECTRUM


DEFINES += HAVE_IO_USB HAVE_L4_USBLIB IO_USB_MAX_ENDPOINTS=7 IO_HID_EP_LENGTH=64 HAVE_USB_APDU

# Compiler, assembler, and linker

ifneq ($(BOLOS_ENV),)
$(info BOLOS_ENV=$(BOLOS_ENV))
CLANGPATH := $(BOLOS_ENV)/clang-arm-fropi/bin/
GCCPATH := $(BOLOS_ENV)/gcc-arm-none-eabi-5_3-2016q1/bin/
else
$(info BOLOS_ENV is not set: falling back to CLANGPATH and GCCPATH)
endif

ifeq ($(CLANGPATH),)
$(info CLANGPATH is not set: clang will be used from PATH)
endif

ifeq ($(GCCPATH),)
$(info GCCPATH is not set: arm-none-eabi-* will be used from PATH)
endif

CC := $(CLANGPATH)clang
CFLAGS += -O3 -Os

AS := $(GCCPATH)arm-none-eabi-gcc
AFLAGS +=

LD := $(GCCPATH)arm-none-eabi-gcc
LDFLAGS += -O3 -Os
LDLIBS += -lm -lgcc -lc

# import rules to compile glyphs(/pone)
include $(BOLOS_SDK)/Makefile.glyphs

# Main rules

all: default

# consider every intermediate target as final to avoid deleting intermediate files
.SECONDARY:

# disable builtin rules that overload the build process (and the debug log !!)
.SUFFIXES:
MAKEFLAGS += -r

SHELL =       /bin/bash
#.ONESHELL:


#GLYPH_FILES := $(addprefix glyphs/,$(sort $(notdir $(shell find glyphs/))))
#GLYPH_DESTC := src/glyphs.c
#GLYPH_DESTH := src/glyphs.h
#$(GLYPH_DESTC) $(GLYPH_DESTH): $(GLYPH_FILES) $(BOLOS_SDK)/icon.py#
#	-rm $@
#	for gif in $(GLYPH_FILES) ; do python $(BOLOS_SDK)/icon.py $$gif glyphcheader ; done > $(GLYPH_DESTH)
#	for gif in $(GLYPH_FILES) ; do python $(BOLOS_SDK)/icon.py $$gif glyphcfile ; done > $(GLYPH_DESTC)

load: all
	python -m ledgerblue.loadApp $(APP_LOAD_PARAMS)

delete:
	python -m ledgerblue.deleteApp $(COMMON_DELETE_PARAMS)

# Import generic rules from the SDK

include $(BOLOS_SDK)/Makefile.rules
