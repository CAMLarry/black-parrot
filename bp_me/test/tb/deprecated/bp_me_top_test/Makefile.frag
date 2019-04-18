TB_PARAMS= -pvalue+mem_els_p=512                       \
           -pvalue+boot_rom_els_p=512                  \
           -pvalue+boot_rom_width_p=512								 \
           -pvalue+cfg_link_addr_width_p=16            \
           -pvalue+cfg_link_data_width_p=32

HDL_DEFINES=+define+BSG_CORE_CLOCK_PERIOD=10

HDL_PARAMS=$(DUT_PARAMS) $(TB_PARAMS) $(HDL_DEFINES)

TOP_MODULE=bp_me_top_test