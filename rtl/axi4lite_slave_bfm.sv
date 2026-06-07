// =============================================================================
// File        : axi4lite_slave_bfm.sv
// Description : AXI4-Lite Slave BFM - 4KB memory model
//               Runs as a module bound to the interface.
// =============================================================================
module axi4lite_slave_bfm #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 1024,
    parameter AW_DELAY   = 0,
    parameter W_DELAY    = 0,
    parameter B_DELAY    = 1,
    parameter AR_DELAY   = 0,
    parameter R_DELAY    = 1
)(
    axi4lite_if.slave_mp vif
);
    // 4KB memory model
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // Initialize
    initial foreach(mem[i]) mem[i] = '0;

    // Reset outputs
    task automatic reset_outputs();
        vif.slave_cb.awready <= 1'b0;
        vif.slave_cb.wready  <= 1'b0;
        vif.slave_cb.bresp   <= 2'b00;
        vif.slave_cb.bvalid  <= 1'b0;
        vif.slave_cb.arready <= 1'b0;
        vif.slave_cb.rdata   <= '0;
        vif.slave_cb.rresp   <= 2'b00;
        vif.slave_cb.rvalid  <= 1'b0;
    endtask

    // =========================================================================
    // Write Channel
    // =========================================================================
    task automatic run_write();
        bit [ADDR_WIDTH-1:0] wr_addr;
        bit [DATA_WIDTH-1:0] wr_data;
        bit [DATA_WIDTH/8-1:0] wr_strb;
        int word_idx;
        forever begin
            while (!vif.slave_cb.awvalid) @(vif.slave_cb);
            repeat(AW_DELAY) @(vif.slave_cb);
            wr_addr = vif.slave_cb.awaddr;
            vif.slave_cb.awready <= 1'b1;
            @(vif.slave_cb);
            vif.slave_cb.awready <= 1'b0;

            while (!vif.slave_cb.wvalid) @(vif.slave_cb);
            repeat(W_DELAY) @(vif.slave_cb);
            wr_data = vif.slave_cb.wdata;
            wr_strb = vif.slave_cb.wstrb;
            vif.slave_cb.wready <= 1'b1;
            @(vif.slave_cb);
            vif.slave_cb.wready <= 1'b0;

            word_idx = wr_addr[11:2];
            if (word_idx >= 0 && word_idx < MEM_DEPTH) begin
                if (wr_strb[0]) mem[word_idx][7:0]   = wr_data[7:0];
                if (wr_strb[1]) mem[word_idx][15:8]  = wr_data[15:8];
                if (wr_strb[2]) mem[word_idx][23:16] = wr_data[23:16];
                if (wr_strb[3]) mem[word_idx][31:24] = wr_data[31:24];
            end

            repeat(B_DELAY) @(vif.slave_cb);
            vif.slave_cb.bresp  <= (wr_addr > 32'h0000_0FFC) ? 2'b10 : 2'b00;
            vif.slave_cb.bvalid <= 1'b1;
            do @(vif.slave_cb); while (!vif.slave_cb.bready);
            vif.slave_cb.bvalid <= 1'b0;
        end
    endtask

    // =========================================================================
    // Read Channel
    // =========================================================================
    task automatic run_read();
        bit [ADDR_WIDTH-1:0] rd_addr;
        bit [DATA_WIDTH-1:0] rd_data;
        int word_idx;
        forever begin
            while (!vif.slave_cb.arvalid) @(vif.slave_cb);
            repeat(AR_DELAY) @(vif.slave_cb);
            rd_addr = vif.slave_cb.araddr;
            vif.slave_cb.arready <= 1'b1;
            @(vif.slave_cb);
            vif.slave_cb.arready <= 1'b0;

            word_idx = rd_addr[11:2];
            rd_data = (word_idx >= 0 && word_idx < MEM_DEPTH) ?
                       mem[word_idx] : 32'hDEAD_BEEF;

            repeat(R_DELAY) @(vif.slave_cb);
            vif.slave_cb.rdata  <= rd_data;
            vif.slave_cb.rresp  <= (rd_addr > 32'h0000_0FFC) ? 2'b10 : 2'b00;
            vif.slave_cb.rvalid <= 1'b1;
            do @(vif.slave_cb); while (!vif.slave_cb.rready);
            vif.slave_cb.rvalid <= 1'b0;
            vif.slave_cb.rdata  <= '0;
        end
    endtask

    // =========================================================================
    // Main
    // =========================================================================
    initial begin
        reset_outputs();
        @(posedge vif.rst_n);
        @(vif.slave_cb);
        fork
            run_write();
            run_read();
        join_none
    end

    // Reset handler
    always @(negedge vif.rst_n) begin
        reset_outputs();
    end

    // Peek/Poke for backdoor access
    function automatic bit [DATA_WIDTH-1:0] peek(bit [ADDR_WIDTH-1:0] addr);
        return mem[addr[11:2]];
    endfunction

    function automatic void poke(bit [ADDR_WIDTH-1:0] addr, bit [DATA_WIDTH-1:0] data);
        mem[addr[11:2]] = data;
    endfunction

endmodule : axi4lite_slave_bfm
