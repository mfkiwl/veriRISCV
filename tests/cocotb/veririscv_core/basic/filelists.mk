# RTL filelist
RTL_FILES += $(CORE_PATH)/pc.v
RTL_FILES += $(CORE_PATH)/IF.v
RTL_FILES += $(CORE_PATH)/regfile.v
RTL_FILES += $(CORE_PATH)/decoder.v
RTL_FILES += $(CORE_PATH)/ID.v
RTL_FILES += $(CORE_PATH)/alu.v
RTL_FILES += $(CORE_PATH)/EX.v
RTL_FILES += $(CORE_PATH)/MEM.v
RTL_FILES += $(CORE_PATH)/WB.v
RTL_FILES += $(CORE_PATH)/lsu.v
RTL_FILES += $(CORE_PATH)/veririscv_core.v
# Include path
COMPILE_ARGS = -I$(CORE_PATH)