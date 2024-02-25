# Project name
NAME := mini_balloons
ROM_FILE_NAME := $(NAME).gb

# Internal rom name to be used
#            123456789012345
ROM_TITLE := "mini balloons"

# -- Directories --
SOURCE_DIR := source
INCLUDE_DIR := include
BUILD_DIR := build
RESOURCE_DIR := resource

# -- Commands --
RGBDS ?= # possible custom root
ASM := $(RGBDS)rgbasm
GFX := $(RGBDS)rgbgfx
LINK := $(RGBDS)rgblink
FIX := $(RGBDS)rgbfix

ASMFLAGS := -Wall
LINKFLAGS := --tiny --wramx --sym $(BUILD_DIR)/$(NAME).sym --map $(BUILD_DIR)/$(NAME).map -p 0xff
FIXFLAGS := --validate --mbc-type ROM_ONLY --pad-value 0xff --title $(ROM_TITLE)
GFX_2BPP_FLAGS :=
GFX_MAP_FLAGS := --unique-tiles
SHH ?= @

# Find sources
SOURCE_FILES := $(shell find $(SOURCE_DIR) -name '*.asm')
OBJECT_FILES := $(SOURCE_FILES:%.asm=$(BUILD_DIR)/%.o)
DEPS_FILES := $(OBJECT_FILES:%.o=%.d)

BUILD_SRC_DIR := $(BUILD_DIR)/$(SOURCE_DIR)
BUILD_RES_DIR := $(BUILD_DIR)/$(RESOURCE_DIR)

# Find resources
RES_2BPP_PNGS := $(shell find $(RESOURCE_DIR) -name '*.2bpp.png')
RES_MAP_PNGS := $(shell find $(RESOURCE_DIR) -name '*.map.png')
RES_2BPP_OUTS := $(RES_2BPP_PNGS:%.2bpp.png=$(BUILD_DIR)/%.2bpp)
RES_MAP_OUTS := $(RES_MAP_PNGS:%.map.png=$(BUILD_DIR)/%.map.time)

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.PHONY: clean
.SUFFIXES: .asm .o .inc .gb .gbc .sym .2bpp.png .map.png .2bpp .map
.DELETE_ON_ERROR:

$(BUILD_DIR)/$(ROM_FILE_NAME): $(OBJECT_FILES)
	$(SHH)mkdir -p $(@D)
	$(SHH)$(LINK) $(LINKFLAGS) --output $@ $(OBJECT_FILES)
	$(SHH)$(FIX) $(FIXFLAGS) $@
	@echo $@ done.

$(BUILD_DIR)/%.o: %.asm $(RES_2BPP_OUTS) $(RES_MAP_OUTS) $(BUILD_DIR)/resource/font.1bpp
	$(SHH)mkdir -p $(@D)
	$(SHH)$(ASM) $(ASMFLAGS) --include $(BUILD_RES_DIR) --include $(INCLUDE_DIR) --dependfile $(@:%.o=%.d) --output $@ $<
	@echo assembled $<

$(BUILD_DIR)/%.2bpp: %.2bpp.png
	$(SHH)mkdir -p $(@D)
	$(SHH)$(GFX) $(GFX_2BPP_FLAGS) --output $@ $<
	@echo converted $<

$(BUILD_DIR)/%.map.time: %.map.png
	$(SHH)mkdir -p $(@D)
	$(SHH)$(GFX) $(GFX_MAP_FLAGS) --tilemap $(@:%.map.time=%.map) --output $(@:%.map.time=%.2bpp) $< && \
	touch $@ && \
	if [ $$(du -b $(@:%.map.time=%.2bpp) | cut -f 1) -gt 2048 ]; \
		then echo "warning: $*.map.png produced $(@:%.map.time=%.2bpp) that is larger than a 128-tile VRAM block."; fi
	@echo converted $<

$(BUILD_DIR)/resource/font.1bpp: $(RESOURCE_DIR)/font.1bpp.png
	$(SHH)mkdir -p $(@D)
	$(SHH)$(GFX) -d 1 --output $@ $<
	@echo converted $<

clean:
	$(SHH)rm -r ./$(BUILD_DIR)
	@echo cleaned $(BUILD_DIR).

-include $(DEPS_FILES)
