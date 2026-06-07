# =============================================================================
# File    : waves.tcl  - Batch SHM probe for UVM TB
# =============================================================================
database -open waves -into waves.shm -default -shm
probe -create -shm -all -depth all tb_top
probe -create -shm tb_top.axi_if.clk
probe -create -shm tb_top.axi_if.rst_n
probe -create -shm tb_top.axi_if.awaddr
probe -create -shm tb_top.axi_if.awvalid
probe -create -shm tb_top.axi_if.awready
probe -create -shm tb_top.axi_if.wdata
probe -create -shm tb_top.axi_if.wstrb
probe -create -shm tb_top.axi_if.wvalid
probe -create -shm tb_top.axi_if.wready
probe -create -shm tb_top.axi_if.bresp
probe -create -shm tb_top.axi_if.bvalid
probe -create -shm tb_top.axi_if.bready
probe -create -shm tb_top.axi_if.araddr
probe -create -shm tb_top.axi_if.arvalid
probe -create -shm tb_top.axi_if.arready
probe -create -shm tb_top.axi_if.rdata
probe -create -shm tb_top.axi_if.rresp
probe -create -shm tb_top.axi_if.rvalid
probe -create -shm tb_top.axi_if.rready
run
puts "=== waves.shm written. Open with: simvision waves.shm ==="
