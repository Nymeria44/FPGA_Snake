create_clock -period 20.000 [get_ports {clk}]

# Automatically derive PLL output clocks
derive_pll_clocks