# =============================================================================
# File    : simvision.tcl
# Usage   : xrun ... -gui -input simvision.tcl
# =============================================================================
database require waves -hints { file waves.shm }
window new WaveWindow -name "AXI4-Lite UVM Waveforms" -geometry 1600x900

proc add_div {label} { waveform add -divider $label }
proc add_sig {sigs}  { foreach s $sigs { waveform add -signals $s } }

add_div "=== CLOCK & RESET ==="
add_sig { tb_top.clk tb_top.rst_n }

add_div "=== WRITE ADDRESS (AW) ==="
add_sig { tb_top.axi_if.awvalid tb_top.axi_if.awready tb_top.axi_if.awaddr }

add_div "=== WRITE DATA (W) ==="
add_sig { tb_top.axi_if.wvalid tb_top.axi_if.wready tb_top.axi_if.wdata tb_top.axi_if.wstrb }

add_div "=== WRITE RESPONSE (B) ==="
add_sig { tb_top.axi_if.bvalid tb_top.axi_if.bready tb_top.axi_if.bresp }

add_div "=== READ ADDRESS (AR) ==="
add_sig { tb_top.axi_if.arvalid tb_top.axi_if.arready tb_top.axi_if.araddr }

add_div "=== READ DATA (R) ==="
add_sig { tb_top.axi_if.rvalid tb_top.axi_if.rready tb_top.axi_if.rdata tb_top.axi_if.rresp }

# Radix & colors
foreach sig {awaddr wdata araddr rdata} { waveform format -label $sig -radix hex }
foreach sig {wstrb bresp rresp}         { waveform format -label $sig -radix binary }
foreach sig {awvalid awready}  { waveform format -color cyan    -signals "tb_top.axi_if.$sig" }
foreach sig {wvalid wready}    { waveform format -color green   -signals "tb_top.axi_if.$sig" }
foreach sig {bvalid bready}    { waveform format -color yellow  -signals "tb_top.axi_if.$sig" }
foreach sig {arvalid arready}  { waveform format -color magenta -signals "tb_top.axi_if.$sig" }
foreach sig {rvalid rready}    { waveform format -color orange  -signals "tb_top.axi_if.$sig" }

waveform zoom -full
run
waveform zoom -full
puts "=== AXI4-Lite UVM SimVision ready. ==="
