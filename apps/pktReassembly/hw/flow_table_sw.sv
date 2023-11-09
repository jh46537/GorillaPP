parameter PROT_TCP = 8'h06;
parameter PROT_UDP = 8'h11;
parameter TCP_FIN = 0;
parameter TCP_SYN = 1;
parameter TCP_RST = 2;
parameter TCP_PSH = 3;
parameter TCP_FACK = 4;
parameter TCP_URG = 5;
parameter TCP_ECE = 6;
parameter TCP_CWR = 7;
parameter TCP_NS = 8;
parameter PKT_NUM = 1024;
parameter PKT_AWIDTH    = ($clog2(PKT_NUM));
parameter LL_DEPTH      = (PKT_NUM/2);
parameter LL_AWIDTH     = ($clog2(LL_DEPTH));
parameter FT_SUBTABLE   = 4;
parameter FT_SIZE       = 8192;
parameter FT_DEPTH      = (FT_SIZE/FT_SUBTABLE);
parameter FT_AWIDTH     = ($clog2(FT_DEPTH));
parameter PQ_DEPTH      = 8;
parameter PQ_AWIDTH     = ($clog2(PQ_DEPTH));
parameter TUPLE_DWIDTH = (32 + 32 + 16 + 16);
parameter LL_DWIDTH = (1 + 32 + 16 + 16 + PKT_AWIDTH + 1 + 56);
parameter FT_DWIDTH = (1 + TUPLE_DWIDTH + 32 + LL_AWIDTH*2 + 1 +
                       PKT_AWIDTH + 56 + (4 * FT_AWIDTH));
parameter FT_INSERT=1;
parameter FT_UPDATE=2;
parameter FT_DELETE=3;
parameter PQ_OP_FAST_INSERT = 0;
parameter PQ_OP_FAST_DELETE = 1;
parameter TAG_WIDTH = 5;
parameter NUM_THREADS = 16;

typedef struct packed {
    logic [31:0] sIP;
    logic [31:0] dIP;
    logic [15:0] sPort;
    logic [15:0] dPort;
} tuple_t;

typedef struct packed {
    logic [7:0] prot;
    tuple_t tuple;
    logic [31:0] seq;
    logic [15:0] len;               // Payload length
    logic [PKT_AWIDTH-1:0] pktID;
    logic [5:0] empty;
    logic [4:0] flits;              // Total number of flits
    logic [8:0] hdr_len;            // In bytes
    logic [8:0] tcp_flags;
    logic [2:0] pkt_flags;
    logic [1:0] pdu_flag;
    logic [55:0] last_7_bytes;
} metadata_t; // Metadata

typedef struct packed {
    tuple_t tuple;
    logic [FT_AWIDTH-1:0] addr0;
    logic [FT_AWIDTH-1:0] addr1;
    logic [FT_AWIDTH-1:0] addr2;
    logic [FT_AWIDTH-1:0] addr3;
    logic [2:0] opcode;
} fce_meta_t;

typedef struct packed {
    logic valid;
    tuple_t tuple;
    logic [31:0] seq;
    logic [LL_AWIDTH-1:0] pointer;
    logic ll_valid;
    logic [PKT_AWIDTH-1:0] slow_cnt;
    logic [55:0] last_7_bytes;
    logic [FT_AWIDTH-1:0] addr0;
    logic [FT_AWIDTH-1:0] addr1;
    logic [FT_AWIDTH-1:0] addr2;
    logic [FT_AWIDTH-1:0] addr3;
    logic [LL_AWIDTH-1:0] pointer2;
} fce_t; // Flow context entry

typedef struct packed { 
    logic [2:0] ch0_opcode;
    metadata_t ch0_pkt;
} ftCh0Input_t;

typedef struct packed { 
    logic [3:0] flag;
    logic [4:0] ch0_bit_map;
    fce_t ch0_q;
    metadata_t ch0_pkt;
} ftCh0Output_t;

typedef struct packed { 
    logic [2:0] ch1_opcode;
    logic [4:0] ch1_bit_map;
    fce_t ch1_data;
} ftCh1Input_t;

typedef struct packed {
    metadata_t meta;
    logic [TAG_WIDTH-1:0] wait_next;
    logic [TAG_WIDTH-1:0] wait_tail;
    logic is_tail;
} fse_t;

module hash_func (
    input                   clk,
    input                   rst,
    input                   stall,
    input   logic [31:0]    initval,
    input   tuple_t         tuple_in,
    input                   tuple_in_valid,
    output  logic           hashed_valid,
    output  logic [31:0]    hashed
);

logic [31:0] a;
logic [31:0] b;
logic [31:0] c;
logic [31:0] a1;
logic [31:0] b1;
logic [31:0] c1;
logic [31:0] a2;
logic [31:0] b2;
logic [31:0] c2;
logic [31:0] a3;
logic [31:0] b3;
logic [31:0] c3;
logic [31:0] a4;
logic [31:0] b4;
logic [31:0] c4;
logic [31:0] a5;
logic [31:0] b5;
logic [31:0] c5;
logic [31:0] a6;
logic [31:0] b6;
logic [31:0] c6;

logic valid;
logic valid1;
logic valid2;
logic valid3;
logic valid4;
logic valid5;
logic valid6;

logic [95:0] key;
assign key = {tuple_in.sIP, tuple_in.sPort,
              tuple_in.dIP, tuple_in.dPort};

// Pipelined design
always @(posedge clk) begin
    if (!stall) begin
        valid <= tuple_in_valid;
        valid1 <= valid;
        valid2 <= valid1;
        valid3 <= valid2;
        valid4 <= valid3;
        valid5 <= valid4;
        valid6 <= valid5;
        hashed_valid <= valid6;

        a <= 32'hdeadbefb + key[31:0] + initval;
        b <= 32'hdeadbefb + key[63:32] + initval;
        c <= 32'hdeadbefb + key[95:64] + initval;

        a1 <= a;
        b1 <= b;
        c1 <= (c ^ b) - {b[17:0], b[31:18]};

        a2 <= (a1 ^ c1) - {c1[20:0], c1[31:21]};
        b2 <= b1;
        c2 <= c1;

        a3 <= a2;
        b3 <= (b2 ^ a2) - {a2[6:0], a2[31:7]};
        c3 <= c2;

        a4 <= a3;
        b4 <= b3;
        c4 <= (c3 ^ b3) - {b3[15:0], b3[31:16]};

        a5 <= (a4 ^ c4) - {c4[27:0], c4[31:28]};
        b5 <= b4;
        c5 <= c4;

        a6 <= a5;
        b6 <= (b5 ^ a5) - {a5[17:0], a5[31:18]};
        c6 <= c5;

        hashed <= (c6 ^ b6) - {b6[7:0], b6[31:8]};
    end
end

endmodule

module rr_arbiter_4(clk,rst,
    req,grant
);

parameter DWIDTH = 4;

input clk;
input rst;
input [DWIDTH-1:0] req;
output logic [DWIDTH-1:0] grant;

logic [DWIDTH-1:0] mask;
logic [DWIDTH-1:0] req_masked;
logic [DWIDTH-1:0] higher_pri_reqs_1;
logic [DWIDTH-1:0] grant_1;
logic [DWIDTH-1:0] higher_pri_reqs_2;
logic [DWIDTH-1:0] grant_2;
logic no_req_masked;


//simple priority arbitration for masked portion
assign req_masked = req & mask;
assign higher_pri_reqs_1[0] = 1'b0;
assign higher_pri_reqs_1[1] = req_masked[0];
assign higher_pri_reqs_1[2] = req_masked[0]|req_masked[1];
assign higher_pri_reqs_1[3] = req_masked[0]|req_masked[1]|req_masked[2];

assign grant_1 = req_masked & ~higher_pri_reqs_1;

//Simple priority aribration for unmasked portion
assign higher_pri_reqs_2[0] = 1'b0;
assign higher_pri_reqs_2[1] = req[0];
assign higher_pri_reqs_2[2] = req[0]|req[1];
assign higher_pri_reqs_2[3] = req[0]|req[1]|req[2];

assign grant_2 = req & ~higher_pri_reqs_2;

//Use grant_masked if there is any there, otherwise use grant_unmasked
assign no_req_masked = ~(|req_masked);
assign grant = ({DWIDTH{no_req_masked}} & grant_2) | grant_1;

always @(posedge clk)
begin
    if (rst) begin
        mask <= {DWIDTH{1'b1}};
    end else begin
        if (|req_masked) begin //which arbiter was used
            mask <= higher_pri_reqs_1;
        end else begin
            if (|req) begin //Only update if there's a req
                mask <= higher_pri_reqs_2;
            end else begin
                mask <= mask;
            end
        end
    end
end

endmodule

module para_Q (
    input logic         clk,
    input logic         rst,

    // Port A
    input tuple_t       addr_a,
    input fce_t         data_a,
    input logic         rden_a,
    input logic         wren_a,
    output logic        rd_valid_a, // 2 cycle delay
    output logic        rd_hit_a,   // Hit in queue?
    output fce_t        q_a,

    // Port B
    input tuple_t       addr_b,
    input fce_t         data_b,
    input logic         rden_b,
    input logic         wren_b,
    output logic        rd_valid_b, // 2 cycle delay
    output logic        rd_hit_b,   // Hit in queue?
    output fce_t        q_b,

    // Insert/Delete operations
    input logic         op_en,
    input logic         op_id, // PQ_OP_FAST_{INSERT, DELETE}
    input fce_t         op_data,

    // Deque operation
    input logic         deque_en,
    output fce_t        deque_data,
    output logic        deque_done, // Raised when deque completes

    // Error signals
    output logic [7:0]  error,
    output logic        is_error_fatal,

    // Debug signals
    output logic        full,
    output logic        empty,
    input logic         debug
);

/**
 * Input pipeline registers.
 */
// Port R/Ws
fce_t data_a_r;
logic rden_a_r;
logic wren_a_r;
fce_t data_b_r;
logic rden_b_r;
logic wren_b_r;

// Insert, delete, deque
logic op_en_r;
logic op_id_r;
fce_t op_data_r;
logic deque_en_r;

// Housekeeping
fce_t entries[PQ_DEPTH-1:0]; // Queue entries
logic [PQ_AWIDTH:0] valid_count; // No. of valid entries
logic [PQ_DEPTH-1:0] is_valid; // Valid entries bitvector
logic [PQ_DEPTH-1:0] is_hit_a_r; // Hits (Port A) bitvector
logic [PQ_DEPTH-1:0] is_hit_b_r; // Hits (Port B) bitvector
logic [PQ_DEPTH-1:0] is_hit_delete_r; // Hits (Delete) bitvector

logic is_deque; // Perform a deque on this cycle
logic is_delete; // Perform a delete on this cycle
logic is_insert; // Perform an insert on this cycle
logic [PQ_DEPTH-1:0] shift_vec; // Entries-to-shift bitvector
logic [PQ_DEPTH-1:0] first_empty; // Left-most empty entry (one-hot)

// Error states and signals
localparam ERROR_FATAL_INSERT_FULL  = 8'b1;      // Inserting into a full queue
localparam ERROR_FATAL_A_B_COLLIDE  = 8'b1 << 1; // Accesses A, B incompatible
localparam ERROR_FATAL_DUPLICATES   = 8'b1 << 2; // Detected duplicate entries
localparam ERROR_FATAL_CORRUPT_Q    = 8'b1 << 3; // Queue state is corrupted
localparam ERROR_FATAL_DEQUE_OP     = 8'b1 << 4; // Same-cycle deque/delete
localparam ERROR_DELETE_NO_ENTRY    = 8'b1 << 5; // Entry to delete DNE
localparam ERROR_WRITE_NO_ENTRY     = 8'b1 << 6; // Entry to write DNE
localparam ERROR_AB_OP_COLLIDE      = 8'b1 << 7; // Accesses A/B and op collide

localparam ERROR_FATAL_MASK = (ERROR_FATAL_INSERT_FULL  |
                               ERROR_FATAL_A_B_COLLIDE  |
                               ERROR_FATAL_DUPLICATES   |
                               ERROR_FATAL_CORRUPT_Q    |
                               ERROR_FATAL_DEQUE_OP     );
// Queue state corrupted?
logic queue_corrupted;

int i;
always @(*) begin
    for (i = 0; i < PQ_DEPTH; i++) begin
        is_valid[i] = entries[i].valid;
    end
end

// Deque, delete, insert signals
assign is_deque = deque_en_r;
assign is_delete = (is_hit_delete_r != 0);
assign is_insert = (op_en_r & (op_id_r == PQ_OP_FAST_INSERT));

// Shift bitvector
assign shift_vec[0] = deque_en_r | is_hit_delete_r[0];
assign shift_vec[1] = shift_vec[0] | is_hit_delete_r[1];
assign shift_vec[2] = shift_vec[1] | is_hit_delete_r[2];
assign shift_vec[3] = shift_vec[2] | is_hit_delete_r[3];
assign shift_vec[4] = shift_vec[3] | is_hit_delete_r[4];
assign shift_vec[5] = shift_vec[4] | is_hit_delete_r[5];
assign shift_vec[6] = shift_vec[5] | is_hit_delete_r[6];
assign shift_vec[7] = shift_vec[6] | is_hit_delete_r[7];

// First empty entry (and valid count)
always @(*) begin
    queue_corrupted = 0;
    valid_count = 0;
    first_empty = 0;
    case (is_valid)
        8'b00000000: begin
            valid_count = 0;
            first_empty = 8'b00000001;
        end
        8'b00000001: begin
            valid_count = 1;
            first_empty = 8'b00000010;
        end
        8'b00000011: begin
            valid_count = 2;
            first_empty = 8'b00000100;
        end
        8'b00000111: begin
            valid_count = 3;
            first_empty = 8'b00001000;
        end
        8'b00001111: begin
            valid_count = 4;
            first_empty = 8'b00010000;
        end
        8'b00011111: begin
            valid_count = 5;
            first_empty = 8'b00100000;
        end
        8'b00111111: begin
            valid_count = 6;
            first_empty = 8'b01000000;
        end
        8'b01111111: begin
            valid_count = 7;
            first_empty = 8'b10000000;
        end
        8'b11111111: begin
            valid_count = 8;
            first_empty = 8'b00000000;
        end
        default: begin
            queue_corrupted = 1;
        end
    endcase
end

// Input pipeline registers
always @( posedge clk) begin
    op_en_r <= op_en;
    op_id_r <= op_id;
    data_a_r <= data_a;
    rden_a_r <= rden_a;
    wren_a_r <= wren_a;
    data_b_r <= data_b;
    rden_b_r <= rden_b;
    wren_b_r <= wren_b;
    op_data_r <= op_data;
    deque_en_r <= deque_en;
end

always @( posedge clk) begin
    if (rst) begin
        for (i = 0; i < PQ_DEPTH; i++) begin
            entries[i] <= 0; // Clear queue
        end
        // Output signals
        q_a <= 0;
        q_b <= 0;
        error <= 0;
        rd_valid_a <= 0;
        rd_valid_b <= 0;
        deque_data <= 0;
        deque_done <= 0;
        // Intermediate signals
        is_hit_a_r <= 0;
        is_hit_b_r <= 0;
        is_hit_delete_r <= 0;
    end
    else begin
        /**
         * Set error state. Note: If more than one error is triggered
         * on a single cycle, reports the most significant/fatal one.
         */
        // Could not find the entry corresponding to the write access
        if ((wren_a_r & (is_hit_a_r == 0)) |
            (wren_b_r & (is_hit_b_r == 0))) begin
            error <= (error | ERROR_WRITE_NO_ENTRY);
        end
        // Could not find the entry corresponding to the delete op
        if (op_en_r & (op_id_r == PQ_OP_FAST_DELETE) & !is_delete) begin
            error <= (error | ERROR_DELETE_NO_ENTRY);
        end
        // Accessing an entry that's being simultaneously deleted
        if (is_delete & ((is_hit_a_r == is_hit_delete_r) |
                         (is_hit_b_r == is_hit_delete_r))) begin
            error <= (error | ERROR_AB_OP_COLLIDE);
        end
        // Attempting to deque and delete on the same cycle
        if (is_deque & is_delete) begin
            error <= (error | ERROR_FATAL_DEQUE_OP);
        end
        // Accesses A and B collide in an undefined way
        if ((is_hit_a_r != 0) & (is_hit_a_r == is_hit_b_r) & wren_a_r) begin
            error <= (error | ERROR_FATAL_A_B_COLLIDE);
        end
        // Inserting into a full queue
        if (is_insert & full & !shift_vec[PQ_DEPTH-1]) begin
            error <= (error | ERROR_FATAL_INSERT_FULL);
        end
        // Queue is corrupted
        if (queue_corrupted) begin
            error <= (error | ERROR_FATAL_CORRUPT_Q);
        end

        // Pipeline stage 0: Compute hit-vectors. In order to maintain a con-
        // sistent view of the queue across pipeline stages, changes to queue
        // entries in the next pipeline stage must reflect immediately in the
        // hit vector computation.
        for (i = 0; i < PQ_DEPTH-1; i++) begin

            // Not shifting, use queue positions as-is
            if (!shift_vec[i]) begin
                is_hit_a_r[i] <= (entries[i].valid                          &
                                  (rden_a | wren_a)                         &
                                  (addr_a == entries[i].tuple)              );

                is_hit_b_r[i] <= (entries[i].valid                          &
                                  (rden_b | wren_b)                         &
                                  (addr_b == entries[i].tuple)              );

                is_hit_delete_r[i] <= (entries[i].valid                     &
                                       op_en                                &
                                       (op_id == PQ_OP_FAST_DELETE)         &
                                       (op_data.tuple == entries[i].tuple)  );

                // Inserting a new element into the queue
                if (is_insert & first_empty[i]) begin
                    is_hit_a_r[i] <= (op_data_r.valid                        &
                                      (rden_a | wren_a)                      &
                                      (addr_a == op_data_r.tuple)            );

                    is_hit_b_r[i] <= (op_data_r.valid                        &
                                      (rden_b | wren_b)                      &
                                      (addr_b == op_data_r.tuple)            );

                    is_hit_delete_r[i] <= (op_data_r.valid                   &
                                           op_en                             &
                                           (op_id == PQ_OP_FAST_DELETE)      &
                                           (op_data.tuple == op_data_r.tuple));
                end
            end
            // Shifting is enabled. If there was an incoming write or insert
            // to the right of this entry, patch this bit of the hit-vector.
            else begin
                is_hit_a_r[i] <= (entries[i+1].valid                        &
                                  (rden_a | wren_a)                         &
                                  (addr_a == entries[i+1].tuple)            );

                is_hit_b_r[i] <= (entries[i+1].valid                        &
                                  (rden_b | wren_b)                         &
                                  (addr_b == entries[i+1].tuple)            );

                is_hit_delete_r[i] <= (entries[i+1].valid                   &
                                       op_en                                &
                                       (op_id == PQ_OP_FAST_DELETE)         &
                                       (op_data.tuple == entries[i+1].tuple));

                // Inserting a new element into the queue
                if (is_insert & first_empty[i+1]) begin
                    is_hit_a_r[i] <= (op_data_r.valid                        &
                                      (rden_a | wren_a)                      &
                                      (addr_a == op_data_r.tuple)            );

                    is_hit_b_r[i] <= (op_data_r.valid                        &
                                      (rden_b | wren_b)                      &
                                      (addr_b == op_data_r.tuple)            );

                    is_hit_delete_r[i] <= (op_data_r.valid                   &
                                           op_en                             &
                                           (op_id == PQ_OP_FAST_DELETE)      &
                                           (op_data.tuple == op_data_r.tuple));
                end
            end
        end
        // Not shifting. Simply write/insert to this entry.
        if (!shift_vec[PQ_DEPTH-1]) begin
            is_hit_a_r[PQ_DEPTH-1] <= (entries[PQ_DEPTH-1].valid                        &
                                       (rden_a | wren_a)                                &
                                       (addr_a == entries[PQ_DEPTH-1].tuple)            );

            is_hit_b_r[PQ_DEPTH-1] <= (entries[PQ_DEPTH-1].valid                        &
                                       (rden_b | wren_b)                                &
                                       (addr_b == entries[PQ_DEPTH-1].tuple)            );

            is_hit_delete_r[PQ_DEPTH-1] <= (entries[PQ_DEPTH-1].valid                   &
                                            op_en                                       &
                                            (op_id == PQ_OP_FAST_DELETE)                &
                                            (op_data.tuple == entries[PQ_DEPTH-1].tuple));

            if (is_insert & first_empty[PQ_DEPTH-1]) begin
                is_hit_a_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_a | wren_a)                        &
                                           (addr_a == op_data_r.tuple)              );

                is_hit_b_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_b | wren_b)                        &
                                           (addr_b == op_data_r.tuple)              );

                is_hit_delete_r[PQ_DEPTH-1] <= (op_data_r.valid                     &
                                                op_en                               &
                                                (op_id == PQ_OP_FAST_DELETE)        &
                                                (op_data.tuple == op_data_r.tuple)  );
            end
        end
        // Shifting is enabled. If the queue is completely full and
        // there's a pending insertion, the data is inserted here.
        else begin
            is_hit_a_r[PQ_DEPTH-1] <= 0;
            is_hit_b_r[PQ_DEPTH-1] <= 0;
            is_hit_delete_r[PQ_DEPTH-1] <= 0;

            if (is_insert & (first_empty == 0)) begin
                is_hit_a_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_a | wren_a)                        &
                                           (addr_a == op_data_r.tuple)              );

                is_hit_b_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_b | wren_b)                        &
                                           (addr_b == op_data_r.tuple)              );

                is_hit_delete_r[PQ_DEPTH-1] <= (op_data_r.valid                     &
                                                op_en                               &
                                                (op_id == PQ_OP_FAST_DELETE)        &
                                                (op_data.tuple == op_data_r.tuple)  );
            end
        end

        // Pipeline stage 1: Handle the write (ports A, B),
        // insert, and shift logic for each queue entry.
        for (i = 0; i < PQ_DEPTH-1; i++) begin

            // Not shifting. If required, simply update the
            // entry with the data to write or insert.
            if (!shift_vec[i]) begin
                if (wren_a_r & is_hit_a_r[i]) begin
                    entries[i] <= data_a_r;
                end
                else if (wren_b_r & is_hit_b_r[i]) begin
                    entries[i] <= data_b_r;
                end
                else if (is_insert & first_empty[i]) begin
                    entries[i] <= op_data_r;
                end
                // Default: latch entry
            end
            // Shifting is enabled. If there was an incoming write or insert to
            // the right of this entry, apply it here, instead. Since shift_vec
            // is a cascading signal, the subsequent iterations of the loop will
            // also enter this conditional block.
            else begin
                if (wren_a_r & is_hit_a_r[i+1]) begin
                    entries[i] <= data_a_r;
                end
                else if (wren_b_r & is_hit_b_r[i+1]) begin
                    entries[i] <= data_b_r;
                end
                else if (is_insert & first_empty[i+1]) begin
                    entries[i] <= op_data_r;
                end
                else begin
                    entries[i] <= entries[i+1];
                end
            end
        end
        // Not shifting. Simply write/insert to this entry.
        if (!shift_vec[PQ_DEPTH-1]) begin
            if (wren_a_r & is_hit_a_r[PQ_DEPTH-1]) begin
                entries[PQ_DEPTH-1] <= data_a_r;
            end
            else if (wren_b_r & is_hit_b_r[PQ_DEPTH-1]) begin
                entries[PQ_DEPTH-1] <= data_b_r;
            end
            else if (is_insert & first_empty[PQ_DEPTH-1]) begin
                entries[PQ_DEPTH-1] <= op_data_r;
            end
            // Default: latch entry
        end
        // Shifting is enabled. If the queue is completely full and
        // there's a pending insertion, insert the data here. Else,
        // fill this entry with zeros.
        else begin
            if (is_insert & (first_empty == 0)) begin
                entries[PQ_DEPTH-1] <= op_data_r;
            end
            else begin
                entries[PQ_DEPTH-1] <= 0;
            end
        end

        // Handle reads for Port A
        rd_hit_a <= (is_hit_a_r != 0) & rden_a_r;
        rd_valid_a <= rden_a_r;
        case (is_hit_a_r)
            8'b00000000: begin
                q_a <= 0;
            end
            8'b00000001: begin
                q_a <= entries[0];
            end
            8'b00000010: begin
                q_a <= entries[1];
            end
            8'b00000100: begin
                q_a <= entries[2];
            end
            8'b00001000: begin
                q_a <= entries[3];
            end
            8'b00010000: begin
                q_a <= entries[4];
            end
            8'b00100000: begin
                q_a <= entries[5];
            end
            8'b01000000: begin
                q_a <= entries[6];
            end
            8'b10000000: begin
                q_a <= entries[7];
            end
            // Detected duplicate entries!
            default: begin
                error <= (error | ERROR_FATAL_DUPLICATES);
            end
        endcase

        // Handle reads for Port B
        rd_hit_b <= (is_hit_b_r != 0) & rden_b_r;
        rd_valid_b <= rden_b_r;
        case (is_hit_b_r)
            8'b00000000: begin
                q_b <= 0;
            end
            8'b00000001: begin
                q_b <= entries[0];
            end
            8'b00000010: begin
                q_b <= entries[1];
            end
            8'b00000100: begin
                q_b <= entries[2];
            end
            8'b00001000: begin
                q_b <= entries[3];
            end
            8'b00010000: begin
                q_b <= entries[4];
            end
            8'b00100000: begin
                q_b <= entries[5];
            end
            8'b01000000: begin
                q_b <= entries[6];
            end
            8'b10000000: begin
                q_b <= entries[7];
            end
            // Detected duplicate entries!
            default: begin
                error <= (error | ERROR_FATAL_DUPLICATES);
            end
        endcase

        // If addresses for Ports A, B collide and
        // wren_b is set, forward B's write to q_a.
        if (rden_a_r & wren_b_r & (is_hit_a_r == is_hit_b_r)) begin
            q_a <= data_b_r;
        end

        // Handle deque output
        deque_data <= entries[0];
        deque_done <= 0;
        if (is_deque) begin
            deque_done <= 1;

            // If required, forward the write
            // from ports A, B to the output.
            if (wren_a_r & is_hit_a_r[0]) begin
                deque_data <= data_a_r;
            end
            else if (wren_b_r & is_hit_b_r[0]) begin
                deque_data <= data_b_r;
            end
            // Default: output list head
        end
    end
    // Debug
    if (debug) begin
        $display("Number of valid entries: %d", valid_count);
        $display("Valid vector: %b", is_valid);
        $display("Shift vector: %b", shift_vec);
        $display("Delete vector: %b", is_hit_delete_r);
        $display("1st empty entry: %b", first_empty);
        $display("Port A's hit vector: %b", is_hit_a_r);
        $display("Port B's hit vector: %b", is_hit_b_r);
        $display("Performing deque? %d", is_deque);
        $display("Performing delete? %d", is_delete);
        $display("Performing insert? %d", is_insert);
        $display("Global error state: %b", error);
        $display("Is error(s) fatal? %d\n", is_error_fatal);
    end
end

// Error signals
assign is_error_fatal = ((error & ERROR_FATAL_MASK) != 0);

// Debug signals
assign empty    = (is_valid == 0);
assign full     = (is_valid == 8'b11111111);

endmodule


module flow_table(
    input   logic                   clk,
    input   logic                   rst,

    // Read channel 0
    input   fce_meta_t              ch0_meta,
    input   logic                   ch0_rden,
    output  fce_t                   ch0_q,
    output  logic                   ch0_rd_valid,
    output  logic [FT_SUBTABLE:0]   ch0_bit_map,
    output  logic                   ch0_rd_stall,

    // Write channel 1
    input   logic [2:0]             ch1_opcode,
    input   logic [FT_SUBTABLE:0]   ch1_bit_map,
    input   logic                   ch1_wren,
    input   fce_t                   ch1_data,
    output  logic                   ch1_insert_stall,

    // Read channel 2
    input   fce_meta_t              ch2_meta,
    input   logic                   ch2_rden,
    output  logic                   ch2_ready,
    output  fce_t                   ch2_q,
    output  logic                   ch2_rd_valid,

    // Write channel 3
    input   logic [2:0]             ch3_opcode,
    input   logic                   ch3_wren,
    output  logic                   ch3_ready,
    input   fce_t                   ch3_data,
    input   logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt
);

logic [FT_AWIDTH-1:0]   ft0_addr_a;
logic [FT_AWIDTH-1:0]   ft0_addr_b;
fce_t                   ft0_data_a;
fce_t                   ft0_data_b;
logic                   ft0_rden_a;
logic                   ft0_rden_b;
logic                   ft0_wren_a;
logic                   ft0_wren_b;
fce_t                   ft0_q_a;
fce_t                   ft0_q_b;
fce_t                   ft0_odata_a;
fce_t                   ft0_odata_b;
fce_t                   ft0_data_a_r1;
fce_t                   ft0_data_a_r2;
fce_t                   ft0_data_b_r1;
fce_t                   ft0_data_b_r2;
logic                   rdw0_a;
logic                   rdw0_a_r1;
logic                   rdw0_a_r2;
logic                   rdw0_b;
logic                   rdw0_b_r1;
logic                   rdw0_b_r2;
fce_t                   ft0_q_b_r;

logic [FT_AWIDTH-1:0]   ft1_addr_a;
logic [FT_AWIDTH-1:0]   ft1_addr_b;
fce_t                   ft1_data_a;
fce_t                   ft1_data_b;
logic                   ft1_rden_a;
logic                   ft1_rden_b;
logic                   ft1_wren_a;
logic                   ft1_wren_b;
fce_t                   ft1_q_a;
fce_t                   ft1_q_b;
fce_t                   ft1_odata_a;
fce_t                   ft1_odata_b;
fce_t                   ft1_data_a_r1;
fce_t                   ft1_data_a_r2;
fce_t                   ft1_data_b_r1;
fce_t                   ft1_data_b_r2;
logic                   rdw1_a;
logic                   rdw1_a_r1;
logic                   rdw1_a_r2;
logic                   rdw1_b;
logic                   rdw1_b_r1;
logic                   rdw1_b_r2;
fce_t                   ft1_q_b_r;

logic [FT_AWIDTH-1:0]   ft2_addr_a;
logic [FT_AWIDTH-1:0]   ft2_addr_b;
fce_t                   ft2_data_a;
fce_t                   ft2_data_b;
logic                   ft2_rden_a;
logic                   ft2_rden_b;
logic                   ft2_wren_a;
logic                   ft2_wren_b;
fce_t                   ft2_q_a;
fce_t                   ft2_q_b;
fce_t                   ft2_odata_a;
fce_t                   ft2_odata_b;
fce_t                   ft2_data_a_r1;
fce_t                   ft2_data_a_r2;
fce_t                   ft2_data_b_r1;
fce_t                   ft2_data_b_r2;
logic                   rdw2_a;
logic                   rdw2_a_r1;
logic                   rdw2_a_r2;
logic                   rdw2_b;
logic                   rdw2_b_r1;
logic                   rdw2_b_r2;
fce_t                   ft2_q_b_r;

logic [FT_AWIDTH-1:0]   ft3_addr_a;
logic [FT_AWIDTH-1:0]   ft3_addr_b;
fce_t                   ft3_data_a;
fce_t                   ft3_data_b;
logic                   ft3_rden_a;
logic                   ft3_rden_b;
logic                   ft3_wren_a;
logic                   ft3_wren_b;
fce_t                   ft3_q_a;
fce_t                   ft3_q_b;
fce_t                   ft3_odata_a;
fce_t                   ft3_odata_b;
fce_t                   ft3_data_a_r1;
fce_t                   ft3_data_a_r2;
fce_t                   ft3_data_b_r1;
fce_t                   ft3_data_b_r2;
logic                   rdw3_a;
logic                   rdw3_a_r1;
logic                   rdw3_a_r2;
logic                   rdw3_b;
logic                   rdw3_b_r1;
logic                   rdw3_b_r2;
fce_t                   ft3_q_b_r;

logic rd_valid_a;
logic rd_valid_a_r;
logic rd_valid_b;
logic rd_valid_b_r;
logic [FT_SUBTABLE:0] ft_hit;
logic [FT_SUBTABLE:0] ft_hit_b;
logic [FT_SUBTABLE-1:0] ft_empty;
logic [FT_SUBTABLE-1:0] ft_empty_r;

// Signal for para_Q
tuple_t      q_addr_a;
fce_t        q_data_a;
logic        q_rden_a;
logic        q_wren_a;
logic        q_rd_valid_a; // 2 cycle delay
logic        q_rd_hit_a;   // Hit in queue?
fce_t        q_q_a;
tuple_t      q_addr_b;
fce_t        q_data_b;
logic        q_rden_b;
logic        q_wren_b;
logic        q_rd_valid_b; // 2 cycle delay
logic        q_rd_hit_b;   // Hit in queue?
fce_t        q_q_b;
logic        q_op_en;
logic        q_op_id; // PQ_OP_FAST_{INSERT, DELETE}
fce_t        q_op_data;
logic        q_op_stall; // While high, keep op_en high
logic        q_deque_en;
fce_t        q_deque_data;
logic        q_deque_done; // Raised when deque completes
logic [7:0]  q_error;
logic        q_is_error_fatal;
logic        q_full;
logic        q_empty;
logic        q_debug;

logic        q_deque_en_r;
logic        q_deque_done_r;
logic        q_rd_valid_a_r;
logic        q_rd_hit_a_r1;
logic        q_rd_hit_a_r2;
fce_t        q_q_a_r;
logic        q_rd_valid_b_r;
logic        q_rd_hit_b_r1;
logic        q_rd_hit_b_r2;
fce_t        q_q_b_r;

fce_t        q_odata_a;
fce_t        q_odata_b;
fce_t        q_data_b_r1;
fce_t        q_data_b_r2;
fce_t        q_data_a_r1;
fce_t        q_data_a_r2;
logic        rdwq_a;
logic        rdwq_a_r1;
logic        rdwq_a_r2;
logic        rdwq_b;
logic        rdwq_b_r1;
logic        rdwq_b_r2;
logic        q_empty_r;
logic        q_rden_a_r1;

typedef enum {
    P_ARB,
    P_LOOKUP,
    P_FILL,
    P_EVIC,
    SLOW_UPDATE,
    SLOW_UPDATE_WAIT,
    SLOW_LOOKUP_WAIT,
    SLOW_LOOKUP
} place_t;
place_t p_state;

logic [3:0]  req;
logic [3:0]  grant;
tuple_t      lookup_tuple;
tuple_t      lookup_tuple_r1;
tuple_t      lookup_tuple_r2;
tuple_t      lookup_tuple_b;
tuple_t      lookup_tuple_b_r1;
tuple_t      lookup_tuple_b_r2;

logic        head_busy;
logic        slow_busy;
logic        slow_conflict;
logic        fast_busy;
logic        insert;
logic        evict;
fce_t        evict_data;
logic [1:0]  random;

logic [FT_SUBTABLE:0]   ch0_bit_map_int;
tuple_t                 ch0_tuple_r1;
tuple_t                 ch0_tuple_latch;
tuple_t                 ch0_tuple_latch_r;
tuple_t                 ch0_tuple_r3;
logic                   ch0_rden_r1;
logic                   ch0_rden_r2;
logic                   ch0_rden_r3;
fce_t                   ch1_data_r1;
fce_t                   ch1_data_r2;
logic [FT_SUBTABLE:0]   ch2_bit_map;
fce_t                   ch3_data_r;
logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt_r;

///////// Lookup operation /////////////////////////
assign ft0_rden_a = ch0_rden & !ch0_rd_stall;
assign ft1_rden_a = ch0_rden & !ch0_rd_stall;
assign ft2_rden_a = ch0_rden & !ch0_rd_stall;
assign ft3_rden_a = ch0_rden & !ch0_rd_stall;
assign q_rden_a   = ch0_rden & !ch0_rd_stall;

// ch1 and ch0 use the same BRAM port. wr has higher priority
assign ft0_addr_a   = ch1_wren ? ch1_data.addr0 : ch0_meta.addr0;
assign ft1_addr_a   = ch1_wren ? ch1_data.addr1 : ch0_meta.addr1;
assign ft2_addr_a   = ch1_wren ? ch1_data.addr2 : ch0_meta.addr2;
assign ft3_addr_a   = ch1_wren ? ch1_data.addr3 : ch0_meta.addr3;
assign q_addr_a     = ch1_wren ? ch1_data.tuple : ch0_meta.tuple;
assign lookup_tuple = ch0_meta.tuple;

// Use q_a results to check whether or not it is a hit. The
// rest of the fields maybe changed by other souce later.
assign ft_hit[0] = (lookup_tuple_r2 == ft0_q_a.tuple) & ft0_q_a.valid;
assign ft_hit[1] = (lookup_tuple_r2 == ft1_q_a.tuple) & ft1_q_a.valid;
assign ft_hit[2] = (lookup_tuple_r2 == ft2_q_a.tuple) & ft2_q_a.valid;
assign ft_hit[3] = (lookup_tuple_r2 == ft3_q_a.tuple) & ft3_q_a.valid;
assign ft_hit[4] = q_rd_hit_a;

// Two cycle rd delay
always @(posedge clk) begin
    if (rst) begin
        rd_valid_a_r <= 0;
        rd_valid_a   <= 0;
    end
    else begin
        rd_valid_a_r <= ft0_rden_a;
        rd_valid_a   <= rd_valid_a_r;
    end
    q_rden_a_r1 <= q_rden_a;

    rd_valid_b_r <= ft0_rden_b;
    rd_valid_b   <= rd_valid_b_r;

    lookup_tuple_r1 <= lookup_tuple;
    lookup_tuple_r2 <= lookup_tuple_r1;
    lookup_tuple_b_r1 <= lookup_tuple_b;
    lookup_tuple_b_r2 <= lookup_tuple_b_r1;

    q_deque_en_r <= q_deque_en;
    q_deque_done_r <= q_deque_done;
end

// Third cycle for timing optimization
always @(posedge clk) begin
    if (rst) begin
        ch0_rd_valid <= 0;
        ch0_bit_map <= 0;
    end
    else begin
        ch0_rd_valid <= rd_valid_a;
        ch0_bit_map <= ch0_bit_map_int;
    end
    case (ch0_bit_map_int)
        5'b0_0001: ch0_q <= ft0_odata_a;
        5'b0_0010: ch0_q <= ft1_odata_a;
        5'b0_0100: ch0_q <= ft2_odata_a;
        5'b0_1000: ch0_q <= ft3_odata_a;
        5'b1_0000: ch0_q <= q_odata_a;
        default: ch0_q <= 0;
    endcase
end
assign ch0_rd_stall = (rd_valid_a_r | rd_valid_a | ch0_rd_valid |
                       ch1_wren | (p_state == P_LOOKUP) | (p_state == P_FILL)
                       | q_deque_done_r | slow_conflict);

always @(posedge clk) begin
    if (!rst) begin
        assert(!(rdw0_a | rdw1_a | rdw2_a | rdw3_a | rdwq_a))
        else begin
            $error("Slow path write while fast path read at the same cycle");
            $finish;
        end
        assert(!(rdw0_b | rdw1_b | rdw2_b | rdw3_b | rdwq_b))
        else begin
            $error("Slow path read while fast path write at the same cycle");
            $finish;
        end
    end
end

// Decide the odata
always @(*) begin
    // Default value
    ft0_odata_a = ft0_q_a;
    ft1_odata_a = ft1_q_a;
    ft2_odata_a = ft2_q_a;
    ft3_odata_a = ft3_q_a;
    q_odata_a   = q_q_a;
    ch0_bit_map_int = ft_hit;
    if (rdw0_a_r2) begin
        ft0_odata_a = ft0_data_b_r2;
        ch0_bit_map_int = 5'b0_0001;
    end
    if (rdw1_a_r2) begin
        ft1_odata_a = ft1_data_b_r2;
        ch0_bit_map_int = 5'b0_0010;
    end
    if (rdw2_a_r2) begin
        ft2_odata_a = ft2_data_b_r2;
        ch0_bit_map_int = 5'b0_0100;
    end
    if (rdw3_a_r2) begin
        ft3_odata_a = ft3_data_b_r2;
        ch0_bit_map_int = 5'b0_1000;
    end
    if (rdwq_a_r2) begin
        q_odata_a = q_data_b_r2;
        ch0_bit_map_int = 5'b1_0000;
    end
end

///////// Forward new data for read-during-write. /////////////////////////
// Support it outside of BRAM as M20K does not support new data internally.
assign rdw0_a = ft0_rden_a & ft0_wren_b & (ft0_addr_a == ft0_addr_b);
assign rdw1_a = ft1_rden_a & ft1_wren_b & (ft1_addr_a == ft1_addr_b);
assign rdw2_a = ft2_rden_a & ft2_wren_b & (ft2_addr_a == ft2_addr_b);
assign rdw3_a = ft3_rden_a & ft3_wren_b & (ft3_addr_a == ft3_addr_b);
assign rdwq_a = q_rden_a   & q_wren_b   & (q_addr_a == q_addr_b);
assign rdw0_b = ft0_rden_b & ft0_wren_a & (ft0_addr_b == ft0_addr_a);
assign rdw1_b = ft1_rden_b & ft1_wren_a & (ft1_addr_b == ft1_addr_a);
assign rdw2_b = ft2_rden_b & ft2_wren_a & (ft2_addr_b == ft2_addr_a);
assign rdw3_b = ft3_rden_b & ft3_wren_a & (ft3_addr_b == ft3_addr_a);
assign rdwq_b = q_rden_b   & q_wren_a   & (q_addr_b == q_addr_a);

// Two cycles delay
always @(posedge clk) begin
    rdw0_a_r1 <= rdw0_a;
    rdw0_a_r2 <= rdw0_a_r1;
    rdw1_a_r1 <= rdw1_a;
    rdw1_a_r2 <= rdw1_a_r1;
    rdw2_a_r1 <= rdw2_a;
    rdw2_a_r2 <= rdw2_a_r1;
    rdw3_a_r1 <= rdw3_a;
    rdw3_a_r2 <= rdw3_a_r1;
    rdwq_a_r1 <= rdwq_a;
    rdwq_a_r2 <= rdwq_a_r1;
    rdw0_b_r1 <= rdw0_b;
    rdw0_b_r2 <= rdw0_b_r1;
    rdw1_b_r1 <= rdw1_b;
    rdw1_b_r2 <= rdw1_b_r1;
    rdw2_b_r1 <= rdw2_b;
    rdw2_b_r2 <= rdw2_b_r1;
    rdw3_b_r1 <= rdw3_b;
    rdw3_b_r2 <= rdw3_b_r1;
    rdwq_b_r1 <= rdwq_b;
    rdwq_b_r2 <= rdwq_b_r1;
    ft0_data_b_r1 <= ft0_data_b;
    ft0_data_b_r2 <= ft0_data_b_r1;
    ft1_data_b_r1 <= ft1_data_b;
    ft1_data_b_r2 <= ft1_data_b_r1;
    ft2_data_b_r1 <= ft2_data_b;
    ft2_data_b_r2 <= ft2_data_b_r1;
    ft3_data_b_r1 <= ft3_data_b;
    ft3_data_b_r2 <= ft3_data_b_r1;
    q_data_b_r1 <= q_data_b;
    q_data_b_r2 <= q_data_b_r1;
end

///////// Update operation /////////////////////////
// The read and write arbirates for addr. If both happen on the same cycle, delay read.
assign update   = ch1_wren & ((ch1_opcode == FT_UPDATE) || (ch1_opcode == FT_DELETE));
assign update_q = ch1_wren & (ch1_opcode == FT_UPDATE) & ch1_bit_map[4];
assign ft0_wren_a = update & ch1_bit_map[0];
assign ft1_wren_a = update & ch1_bit_map[1];
assign ft2_wren_a = update & ch1_bit_map[2];
assign ft3_wren_a = update & ch1_bit_map[3];
assign q_wren_a   = update_q;

assign ft0_data_a = ch1_data;
assign ft1_data_a = ch1_data;
assign ft2_data_a = ch1_data;
assign ft3_data_a = ch1_data;
assign q_data_a   = ch1_data;

///////// Insert/Delete operation /////////////////////////
assign insert     = ch1_wren & ch1_bit_map[4] & (ch1_opcode == FT_INSERT);
assign delete     = ch1_wren & ch1_bit_map[4] & (ch1_opcode == FT_DELETE);

// Evict is another form of inserting, no need to worry about full
assign q_op_en    = (insert & !q_full) | delete | evict;
assign q_op_id    = (insert|evict) ? PQ_OP_FAST_INSERT : PQ_OP_FAST_DELETE;
assign q_op_data  = evict ? evict_data : ch1_data;
assign ch1_insert_stall  = insert & q_full;

///////// Fill/Eviction operation /////////////////////////
// Dequeue the para Q and update the flow table.
assign ft_empty[0] = !ft0_q_b.valid;
assign ft_empty[1] = !ft1_q_b.valid;
assign ft_empty[2] = !ft2_q_b.valid;
assign ft_empty[3] = !ft3_q_b.valid;

///////// Arbiration for port_B /////////////////////////
// Only generate a request during the ARB state.
assign req[0] = (p_state == P_ARB) & !q_empty_r;
assign req[1] = (p_state == P_ARB) & (ch3_wren || ch2_rden);
assign req[2] = 0;
assign req[3] = 0;

assign ch3_ready = grant[1];
assign ch2_ready = grant[1];

assign ft_hit_b[0] = (lookup_tuple_b_r2 == ft0_q_b.tuple) & ft0_q_b.valid;
assign ft_hit_b[1] = (lookup_tuple_b_r2 == ft1_q_b.tuple) & ft1_q_b.valid;
assign ft_hit_b[2] = (lookup_tuple_b_r2 == ft2_q_b.tuple) & ft2_q_b.valid;
assign ft_hit_b[3] = (lookup_tuple_b_r2 == ft3_q_b.tuple) & ft3_q_b.valid;
assign ft_hit_b[4] = q_rd_hit_b;

always @(*) begin
    case (ch2_bit_map)
        5'b0_0001: ch2_q = ft0_odata_b;
        5'b0_0010: ch2_q = ft1_odata_b;
        5'b0_0100: ch2_q = ft2_odata_b;
        5'b0_1000: ch2_q = ft3_odata_b;
        5'b1_0000: ch2_q = q_odata_b;
        default: ch2_q = 0;
    endcase
end
always @(posedge clk) begin
    ft0_data_a_r1 <= ft0_data_a;
    ft0_data_a_r2 <= ft0_data_a_r1;
end
always @(*) begin
    // Default value
    ft0_odata_b = ft0_q_b;
    ft1_odata_b = ft1_q_b;
    ft2_odata_b = ft2_q_b;
    ft3_odata_b = ft3_q_b;
    q_odata_b   = q_q_b;
    ch2_rd_valid = 0;
    ch2_bit_map = ft_hit_b;

    if (p_state == SLOW_LOOKUP) begin
        ch2_rd_valid = rd_valid_b;
    end

    if (rdw0_b_r2) begin
        ft0_odata_b = ft0_data_a_r2;
        ch2_bit_map = 5'b0_0001;
    end
    if (rdw1_b_r2) begin
        ft1_odata_b = ft1_data_a_r2;
        ch2_bit_map = 5'b0_0010;
    end
    if (rdw2_b_r2) begin
        ft2_odata_b = ft2_data_a_r2;
        ch2_bit_map = 5'b0_0100;
    end
    if (rdw3_b_r2) begin
        ft3_odata_b = ft3_data_a_r2;
        ch2_bit_map = 5'b0_1000;
    end
    if (rdwq_b_r2) begin
        q_odata_b = q_data_a_r2;
        ch2_bit_map = 5'b1_0000;
    end
end

// The q_deque_data will show up one cycle later
always @(posedge clk) begin
    q_empty_r <= q_empty;
    ch0_tuple_r1 <= ch0_meta.tuple;

    // ch0_tuple_latch keeps the tuple value before next read
    if (ch0_rden) begin
        ch0_tuple_latch_r <= ch0_meta.tuple;
    end
end
assign ch0_tuple_latch = ch0_rden ? ch0_meta.tuple : ch0_tuple_latch_r;

// Random number used for eviction
always @(posedge clk) begin
    if (rst) begin
        random <= 0;
    end
    else begin
        random <= random + 1;
    end
end

assign head_busy = (q_rden_a & (ch0_meta.tuple == q_deque_data.tuple) |
                    q_rden_a_r1 & (ch0_tuple_r1 == q_deque_data.tuple));

// Start from the rden, until the update is done
assign fast_busy = ch0_rden | ch0_rd_stall;

// When slow path is updating the FT assign p_state == SLOW_UPDATE
assign slow_conflict = slow_busy & ch0_rden & (ch3_data_r.tuple == ch0_meta.tuple);

// One state machine that arbirates all the read/writes using port_b.
always @(posedge clk) begin
    if (rst) begin
        p_state <= P_ARB;
        ft0_rden_b <= 0;
        ft1_rden_b <= 0;
        ft2_rden_b <= 0;
        ft3_rden_b <= 0;
        ft0_wren_b <= 0;
        ft1_wren_b <= 0;
        ft2_wren_b <= 0;
        ft3_wren_b <= 0;
        q_rden_b   <= 0;
        q_wren_b   <= 0;
        q_deque_en <= 0;
        evict      <= 0;
        slow_busy  <= 0;
    end
    else begin
        case (p_state)
            P_ARB: begin
                evict <= 0;
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;
                ft0_wren_b <= 0;
                ft1_wren_b <= 0;
                ft2_wren_b <= 0;
                ft3_wren_b <= 0;
                q_rden_b   <= 0;
                q_wren_b   <= 0;
                q_deque_en <= 0;
                evict      <= 0;
                slow_busy  <= 0;
                case (grant)
                    // Para_Q fill operation
                    4'b0001: begin
                        p_state    <= P_LOOKUP;
                        ft0_rden_b <= 1;
                        ft1_rden_b <= 1;
                        ft2_rden_b <= 1;
                        ft3_rden_b <= 1;
                        ft0_addr_b <= q_deque_data.addr0;
                        ft1_addr_b <= q_deque_data.addr1;
                        ft2_addr_b <= q_deque_data.addr2;
                        ft3_addr_b <= q_deque_data.addr3;
                    end
                    // Slow path lookup and update
                    4'b0010: begin
                        // Read and Write won't happen on the same cycle
                        if (ch3_wren) begin
                            // Same entry is busy
                            if (fast_busy & (ch3_data.tuple == ch0_tuple_latch)) begin
                                p_state <= SLOW_UPDATE_WAIT;
                            end
                            else begin
                                slow_busy  <= 1;
                                p_state    <= SLOW_UPDATE;
                                ft0_rden_b <= 1;
                                ft1_rden_b <= 1;
                                ft2_rden_b <= 1;
                                ft3_rden_b <= 1;
                                q_rden_b   <= 1;
                            end
                            ft0_addr_b <= ch3_data.addr0;
                            ft1_addr_b <= ch3_data.addr1;
                            ft2_addr_b <= ch3_data.addr2;
                            ft3_addr_b <= ch3_data.addr3;
                            q_addr_b   <= ch3_data.tuple;
                            ch3_data_r <= ch3_data;
                            lookup_tuple_b <= ch3_data.tuple;
                            ch3_rel_pkt_cnt_r <= ch3_rel_pkt_cnt;
                        end
                        else begin
                            // Avoid rd/wr conflicts
                            if (ch0_rd_valid & (ch2_meta.tuple == ch0_tuple_latch)) begin
                                p_state <= SLOW_LOOKUP_WAIT;
                            end
                            else begin
                                p_state    <= SLOW_LOOKUP;
                                ft0_rden_b <= 1;
                                ft1_rden_b <= 1;
                                ft2_rden_b <= 1;
                                ft3_rden_b <= 1;
                                q_rden_b   <= 1;
                            end
                            ft0_addr_b <= ch2_meta.addr0;
                            ft1_addr_b <= ch2_meta.addr1;
                            ft2_addr_b <= ch2_meta.addr2;
                            ft3_addr_b <= ch2_meta.addr3;
                            q_addr_b   <= ch2_meta.tuple;
                            lookup_tuple_b <= ch2_meta.tuple;
                        end
                    end
                    default: p_state <= P_ARB;
                endcase
            end
            P_LOOKUP: begin
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;

                ft0_q_b_r <= ft0_q_b;
                ft1_q_b_r <= ft1_q_b;
                ft2_q_b_r <= ft2_q_b;
                ft3_q_b_r <= ft3_q_b;

                if (rd_valid_b) begin
                    ft_empty_r <= ft_empty;
                    if (head_busy) begin
                        p_state <= P_ARB;
                    end
                    else begin
                        // All entries are full
                        if (ft_empty == 0) begin
                            p_state <= P_EVIC;
                            q_deque_en <= 1;
                        end
                        else begin
                            p_state <= P_FILL;
                            q_deque_en <= 1;
                        end
                    end
                end
            end
            P_FILL: begin
                ft0_data_b <= q_deque_data;
                ft1_data_b <= q_deque_data;
                ft2_data_b <= q_deque_data;
                ft3_data_b <= q_deque_data;
                q_deque_en <= 0;
                if (q_deque_done) begin
                    p_state <= P_ARB;

                    // Priority
                    if (ft_empty_r[0]) begin
                        ft0_wren_b <= 1;
                    end
                    else if (ft_empty_r[1]) begin
                        ft1_wren_b <= 1;
                    end
                    else if (ft_empty_r[2]) begin
                        ft2_wren_b <= 1;
                    end
                    else if (ft_empty_r[3]) begin
                        ft3_wren_b <= 1;
                    end
                end
            end
            P_EVIC: begin
                ft0_data_b <= q_deque_data;
                ft1_data_b <= q_deque_data;
                ft2_data_b <= q_deque_data;
                ft3_data_b <= q_deque_data;
                evict <= 0;

                // Deque and overwrite the data in subtable
                q_deque_en <= 0;
                if (q_deque_done) begin
                    p_state <= P_ARB;
                    $display("Evict!");
                    // The queue cannot be full during eviction,
                    // so don't need to check the full signal.
                    evict <= 1;
                    // Overwrite the data in the subtable,
                    // and select right data to insert Q.
                    case (random)
                        2'b00: begin
                            ft0_wren_b <= 1;
                            evict_data <= ft0_q_b_r;
                        end
                        2'b01: begin
                            ft1_wren_b <= 1;
                            evict_data <= ft1_q_b_r;
                        end
                        2'b10: begin
                            ft2_wren_b <= 1;
                            evict_data <= ft2_q_b_r;
                        end
                        2'b11: begin
                            ft3_wren_b <= 1;
                            evict_data <= ft3_q_b_r;
                        end
                    endcase
                end
            end
            SLOW_UPDATE_WAIT: begin
                if (!(fast_busy & (ch3_data.tuple == ch0_tuple_latch))) begin
                    p_state    <= SLOW_UPDATE;
                    ft0_rden_b <= 1;
                    ft1_rden_b <= 1;
                    ft2_rden_b <= 1;
                    ft3_rden_b <= 1;
                    q_rden_b   <= 1;
                    slow_busy  <= 1;
                end
            end
            SLOW_UPDATE: begin
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;
                ft0_wren_b <= 0;
                ft1_wren_b <= 0;
                ft2_wren_b <= 0;
                ft3_wren_b <= 0;
                q_rden_b   <= 0;
                q_wren_b   <= 0;

                ft0_data_b <= ch3_data_r;
                ft1_data_b <= ch3_data_r;
                ft2_data_b <= ch3_data_r;
                ft3_data_b <= ch3_data_r;
                q_data_b   <= ch3_data_r;

                ft0_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                ft1_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                ft2_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                ft3_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                q_data_b.slow_cnt   <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;

                `ifdef DEBUG
                if (rd_valid_b & ch2_bit_map != 0) begin
                    $display("Slow_cnt current %d, release %d, updated %d",
                             (ch2_q.slow_cnt, ch3_rel_pkt_cnt_r),
                             (ch2_q.slow_cnt - ch3_rel_pkt_cnt_r));

                    assert(!(ch2_q.slow_cnt < ch3_rel_pkt_cnt_r))
                    else begin
                        $error("slow_cnt error");
                        $finish;
                    end
                end
                `endif

                // Update data in the flow table. Address is not changed.
                if (rd_valid_b) begin
                    case (ch2_bit_map)
                        5'b0_0001: ft0_wren_b <= 1;
                        5'b0_0010: ft1_wren_b <= 1;
                        5'b0_0100: ft2_wren_b <= 1;
                        5'b0_1000: ft3_wren_b <= 1;
                        5'b1_0000: q_wren_b   <= 1;
                    endcase
                    p_state <= P_ARB;
                end
            end
            SLOW_LOOKUP_WAIT: begin
                if (!(ch0_rd_valid & (lookup_tuple_b == ch0_tuple_latch))) begin
                    p_state    <= SLOW_LOOKUP;
                    ft0_rden_b <= 1;
                    ft1_rden_b <= 1;
                    ft2_rden_b <= 1;
                    ft3_rden_b <= 1;
                    q_rden_b   <= 1;
                end
            end
            SLOW_LOOKUP: begin
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;
                q_rden_b   <= 0;
                // Address is not changed
                if (rd_valid_b) begin
                    p_state <= P_ARB;
                end
            end
            default: begin
                $display("Error state!");
                $finish;
            end
        endcase
    end
end

// Miscellnaeous signals
assign q_debug = 0;

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_0 (
    .address_a  (ft0_addr_a),
    .address_b  (ft0_addr_b),
    .clock      (clk),
    .data_a     (ft0_data_a),
    .data_b     (ft0_data_b),
    .rden_a     (ft0_rden_a),
    .rden_b     (ft0_rden_b),
    .wren_a     (ft0_wren_a),
    .wren_b     (ft0_wren_b),
    .q_a        (ft0_q_a),
    .q_b        (ft0_q_b)
);

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_1 (
    .address_a  (ft1_addr_a),
    .address_b  (ft1_addr_b),
    .clock      (clk),
    .data_a     (ft1_data_a),
    .data_b     (ft1_data_b),
    .rden_a     (ft1_rden_a),
    .rden_b     (ft1_rden_b),
    .wren_a     (ft1_wren_a),
    .wren_b     (ft1_wren_b),
    .q_a        (ft1_q_a),
    .q_b        (ft1_q_b)
);

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_2 (
    .address_a  (ft2_addr_a),
    .address_b  (ft2_addr_b),
    .clock      (clk),
    .data_a     (ft2_data_a),
    .data_b     (ft2_data_b),
    .rden_a     (ft2_rden_a),
    .rden_b     (ft2_rden_b),
    .wren_a     (ft2_wren_a),
    .wren_b     (ft2_wren_b),
    .q_a        (ft2_q_a),
    .q_b        (ft2_q_b)
);

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_3 (
    .address_a  (ft3_addr_a),
    .address_b  (ft3_addr_b),
    .clock      (clk),
    .data_a     (ft3_data_a),
    .data_b     (ft3_data_b),
    .rden_a     (ft3_rden_a),
    .rden_b     (ft3_rden_b),
    .wren_a     (ft3_wren_a),
    .wren_b     (ft3_wren_b),
    .q_a        (ft3_q_a),
    .q_b        (ft3_q_b)
);

para_Q para_q_inst (
    .clk        (clk),
    .rst        (rst),
    // Port A
    .addr_a     (q_addr_a),
    .data_a     (q_data_a),
    .rden_a     (q_rden_a),
    .wren_a     (q_wren_a),
    .rd_valid_a (q_rd_valid_a), // 2 cycles delay
    .rd_hit_a   (q_rd_hit_a),   // Hit in queue?
    .q_a        (q_q_a),

    // Port B
    .addr_b     (q_addr_b),
    .data_b     (q_data_b),
    .rden_b     (q_rden_b),
    .wren_b     (q_wren_b),
    .rd_valid_b (q_rd_valid_b), // 2 cycles delay
    .rd_hit_b   (q_rd_hit_b),   // Hit in queue?
    .q_b        (q_q_b),

    // Insert/Delete operations
    .op_en      (q_op_en),
    .op_id      (q_op_id), // PQ_OP_FAST_{INSERT, DELETE}
    .op_data    (q_op_data),

    // Deque operation
    .deque_en   (q_deque_en),
    .deque_data (q_deque_data),
    .deque_done (q_deque_done), // Raised when deque completes

    // Error signals
    .error             (q_error),
    .is_error_fatal    (q_is_error_fatal),

    // Debug signals
    .full              (q_full),
    .empty             (q_empty),
    .debug             (q_debug)
);

rr_arbiter_4 port_b_arb (
    .clk   (clk),
    .rst   (rst),
    .req   (req),
    .grant (grant)
);

endmodule

module flowTableV
(
    input                        clk,
    input                        rst,

    input  logic                 ch0_req_valid,
    input  logic [TAG_WIDTH-1:0] ch0_req_tag,
    input  ftCh0Input_t          ch0_req_data,
    output logic                 ch0_req_ready,

    output logic                 ch0_rep_valid,
    output logic [TAG_WIDTH-1:0] ch0_rep_tag,
    output ftCh0Output_t         ch0_rep_data,
    input  logic                 ch0_rep_ready,

    input  logic                 ch1_req_valid,
    input  logic [TAG_WIDTH-1:0] ch1_req_tag,
    input  ftCh1Input_t          ch1_req_data,
    output logic                 ch1_req_ready,

    output logic                 ch1_rep_valid,
    output logic [TAG_WIDTH-1:0] ch1_rep_tag,
    output logic [7:0]           ch1_rep_data,
    input  logic                 ch1_rep_ready,

    input  logic                 ch2_req_valid,
    input  logic [TAG_WIDTH-1:0] ch2_req_tag,
    input  ftCh1Input_t          ch2_req_data,
    output logic                 ch2_req_ready
);

tuple_t         h0_tuple_in;
logic           h0_tuple_in_valid;
logic [31:0]    h0_initval;
logic [31:0]    h0_hashed;
logic           h0_hashed_valid;

tuple_t         h1_tuple_in;
logic           h1_tuple_in_valid;
logic [31:0]    h1_initval;
logic [31:0]    h1_hashed;
logic           h1_hashed_valid;

tuple_t         h2_tuple_in;
logic           h2_tuple_in_valid;
logic [31:0]    h2_initval;
logic [31:0]    h2_hashed;
logic           h2_hashed_valid;

tuple_t         h3_tuple_in;
logic           h3_tuple_in_valid;
logic [31:0]    h3_initval;
logic [31:0]    h3_hashed;
logic           h3_hashed_valid;

// Read channel 0
fce_meta_t              ch0_meta;
logic                   ch0_rden;
fce_t                   ch0_q;
logic                   ch0_rd_valid;
logic [FT_SUBTABLE:0]   ch0_bit_map;
logic                   ch0_rd_stall;

// Write channel 1
logic [2:0]             ch1_opcode;
logic [FT_SUBTABLE:0]   ch1_bit_map;
logic                   ch1_wren;
fce_t                   ch1_data;
logic [2:0]             ch1_opcode_i;
logic [FT_SUBTABLE:0]   ch1_bit_map_i;
logic                   ch1_wren_i;
fce_t                   ch1_data_i;
logic                   ch1_insert_stall;

// Read channel 2
fce_meta_t              ch2_meta;
logic                   ch2_rden;
logic                   ch2_ready;
fce_t                   ch2_q;
logic                   ch2_rd_valid;

// Write channel 3
logic [2:0]             ch3_opcode;
logic                   ch3_wren;
logic                   ch3_ready;
fce_t                   ch3_data;
logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt;

logic out_meta_valid, out_meta_valid_n;
logic [TAG_WIDTH-1:0] out_meta_tag, out_meta_tag_n;
ftCh0Output_t out_meta_data;

ftCh0Input_t m0;
ftCh0Input_t m1;
ftCh0Input_t m2;
ftCh0Input_t m3;
ftCh0Input_t m4;
ftCh0Input_t m5;
ftCh0Input_t m6;
ftCh0Input_t m7;

logic [TAG_WIDTH-1:0] ch0_req_tag_vec [0:7];

// Signal for forwarding
logic f_pkt; // Not-forward pkt;
logic ack_pkt; // Not-forward pkt;
logic udp_pkt; // Not-forward pkt;

logic stall;

///////// Forward pkts /////////////////////////
// Packets which are either ACK (0 length) OR
// UDP can be forwarded without touching the HT.
logic forward_meta_valid;
logic forward_meta_ready;
logic [1:0] forward_meta_flag;
logic [TAG_WIDTH-1:0] forward_meta_tag;

assign ack_pkt             = (ch0_req_data.ch0_pkt.tcp_flags == (1'b1 << TCP_FACK)) & (ch0_req_data.ch0_pkt.len == 0);
assign udp_pkt             = (ch0_req_data.ch0_pkt.prot == PROT_UDP);
assign f_pkt               = ack_pkt | udp_pkt;
always_ff @(posedge clk) begin
    if (forward_meta_ready) begin
        if (ch0_req_valid && f_pkt) begin
            forward_meta_valid <= 1'b1;
            forward_meta_flag <= 'b1;
            forward_meta_tag <= ch0_req_tag;
        end else begin
            forward_meta_valid <= 1'b0;
        end
    end
end

assign forward_meta_ready = !out_meta_valid;
assign ch0_rep_valid = forward_meta_valid | out_meta_valid;
assign ch0_rep_data.ch0_q = out_meta_data.ch0_q;
assign ch0_rep_data.ch0_pkt = out_meta_data.ch0_pkt;
assign ch0_rep_data.ch0_bit_map = out_meta_data.ch0_bit_map;
assign ch0_rep_data.flag = out_meta_valid ? out_meta_data.flag : forward_meta_flag;
assign ch0_rep_tag = out_meta_valid ? out_meta_tag : forward_meta_tag;
assign ch0_req_ready = f_pkt ? forward_meta_ready : (!stall);


logic [2:0] state, state_n;
logic [TAG_WIDTH-1:0] tag, tag_n;
logic [TAG_WIDTH-1:0] tag_last, tag_last_n;
logic [TAG_WIDTH-1:0] tag_conflict, tag_conflict_n;
logic [1:0] opcode, opcode_n;
metadata_t meta, meta_n;
metadata_t meta_last, meta_last_n;
logic path_sel;
logic [TAG_WIDTH-1:0] head, head_n;
logic [TAG_WIDTH-1:0] tail, tail_n;
logic new_packet, new_packet_n;
logic new_packet_last, new_packet_last_n;
fse_t fs_table [0:NUM_THREADS-1];
logic [3:0] fs_table_wen0;
logic [3:0] fs_table_wen1;
logic [TAG_WIDTH-1:0] fs_table_waddr0;
fse_t fs_table_wdata0;
logic [TAG_WIDTH-1:0] fs_table_waddr1;
fse_t fs_table_wdata1;
logic [TAG_WIDTH-1:0] fs_table_raddr;
fse_t fs_table_rdata;
logic is_tail, is_tail_n;
logic [NUM_THREADS-1:0] fs_table_running, fs_table_running_n;
logic [47:0] key, key_n;
logic [47:0] key_last, key_last_n;
logic [47:0] fs_table_hash [0:NUM_THREADS-1];
logic [47:0] fs_table_hash_n [0:NUM_THREADS-1];
logic [NUM_THREADS-1:0] conflict, conflict_n;
int i;
logic ch0_rd_ready;
always_comb begin
    state_n = state;
    opcode_n = opcode;
    meta_n = meta;
    meta_last_n = meta_last;
    head_n = head;
    tail_n = tail;
    is_tail_n = is_tail;
    conflict_n = conflict;
    fs_table_running_n = fs_table_running;
    fs_table_hash_n = fs_table_hash;
    key_n = key;
    key_last_n = key_last;
    tag_n = tag;
    tag_last_n = tag_last;
    tag_conflict_n = tag_conflict;
    out_meta_valid_n = 1'b0;
    out_meta_tag_n = out_meta_tag;
    ch0_rden = 1'b0;
    ch0_meta.addr0 = key[11:0];
    ch0_meta.addr1 = key[23:12];
    ch0_meta.addr2 = key[35:24];
    ch0_meta.addr3 = key[47:36];
    ch0_meta.tuple = meta.tuple;
    ch0_meta.opcode = 0;
    ch0_rd_ready = 1'b0;
    stall = 'b1;
    fs_table_wen0 = 'd0;
    fs_table_waddr0 = tag;
    fs_table_wdata0.meta = meta;
    fs_table_wdata0.wait_next = 'd0;
    fs_table_wdata0.wait_tail = 'd0;
    fs_table_wdata0.is_tail = 'b0;
    fs_table_wen1 = 'd0;
    fs_table_waddr1 = head;
    fs_table_wdata1.meta = meta;
    fs_table_wdata1.wait_next = 'd0;
    fs_table_wdata1.wait_tail = 'd0;
    fs_table_wdata1.is_tail = 'b0;
    case (state)
        3'd0: begin
            fs_table_raddr = head;
            if (ch0_rd_valid) begin
                if (!ch1_insert_stall) begin
                    out_meta_valid_n = 1'b1;
                    out_meta_tag_n = tag_last;
                    state_n = 3'd4;
                end
            end else if (h0_hashed_valid) begin
                stall = 1'b0;
                state_n = 3'd1;
                meta_n = m7.ch0_pkt;
                key_n = {h3_hashed, h2_hashed, h1_hashed, h0_hashed};
                tag_n = ch0_req_tag_vec[7];
                fs_table_hash_n[tag_n] = key_n;
                fs_table_raddr = tag_n;
                opcode_n = m7.ch0_opcode;
                if (m7.ch0_opcode == 1) begin
                    fs_table_running_n[tag_n] = 1'b0;
                    out_meta_valid_n = 1'b1;
                    out_meta_tag_n = tag_n;
                end
            end else begin
                stall = 1'b0;
            end
        end
        3'd1: begin
            conflict_n = 'd0;
            for (i = 0; i < NUM_THREADS; i=i+1) begin
                if (fs_table_hash[i] == key && fs_table_running[i]) begin
                    conflict_n[i] = 1'b1;
                end
            end
            if (opcode == 0) begin
                fs_table_wen0 = 4'b1111;
                fs_table_waddr0 = tag;
                fs_table_wdata0.meta = meta;
                fs_table_wdata0.wait_next = tag;
                fs_table_wdata0.wait_tail = tag;
                fs_table_wdata0.is_tail = 1'b1;
                head_n = tag;
                tail_n = tag;
                is_tail_n = 1'b1;
            end else begin
                head_n = fs_table_rdata.wait_next;
                tail_n = fs_table_rdata.wait_tail;
                is_tail_n = fs_table_rdata.is_tail;
            end
            fs_table_raddr = fs_table_rdata.wait_next;

            if (ch0_rd_valid && (!ch1_insert_stall)) begin
                out_meta_valid_n = 1'b1;
                out_meta_tag_n = tag_last;
            end
            state_n = 3'd2;
        end
        3'd2: begin
            fs_table_raddr = head;
            if (!ch0_rd_valid || !ch1_insert_stall) begin
                for (i = 0; i < NUM_THREADS; i=i+1) begin
                    if (conflict[i]) begin
                        fs_table_raddr = i;
                        tag_conflict_n = i;
                    end
                end
                if (opcode == 1) begin
                    if (!is_tail) begin
                        tag_n = head;
                        meta_n = fs_table_rdata.meta;
                        head_n = fs_table_rdata.wait_next;
                        tail_n = fs_table_rdata.wait_tail;
                        fs_table_waddr0 = head;
                        fs_table_wen0 = 6'b0010;
                        fs_table_wdata0.wait_tail = tail;
                        state_n = 3'd3;
                    end else begin
                        state_n = 3'd4;
                    end
                end else begin
                    state_n = 3'd3;
                end

                if (ch0_rd_valid) begin
                    out_meta_valid_n = 1'b1;
                    out_meta_tag_n = tag_last;
                end
            end
        end
        3'd3: begin
            fs_table_raddr = tag;
            if ((conflict == 0) && (!((path_sel != 0) && (key == key_last)))) begin
                // No conflict
                ch0_rden = 1'b1;
                if (!ch0_rd_stall) begin
                    ch0_rd_ready = 1'b1;
                    meta_last_n = meta;
                    tag_last_n = tag;
                    key_last_n = key;
                    if (opcode == 1) begin
                        state_n = 3'd7;
                    end else begin
                        state_n = 3'd0;
                    end
                end
            end else begin
                // Conflict
                ch0_rd_ready = 1'b1;
                fs_table_waddr0 = tag;
                fs_table_wen0 = 4'b0111;
                fs_table_wdata0.wait_next = tag;
                fs_table_wdata0.wait_tail = tag;
                fs_table_wdata0.is_tail = 1'b1;
                state_n = 3'd5;
                if ((path_sel != 0) && (key == key_last)) begin
                    head_n = tag_last;
                    tail_n = tag_last;
                end else begin
                    head_n = tag_conflict;
                    tail_n = fs_table_rdata.wait_tail;
                end
            end

            if (path_sel != 0) begin
                fs_table_running_n[tag_last] = 1'b1;
            end
        end
        3'd4: begin
            // no new packet
            fs_table_raddr = head;
            ch0_rd_ready = 1'b1;
            if (path_sel != 0) begin
                fs_table_running_n[tag_last] = 1'b1;
                state_n = 1'b0;
            end else begin
                if (!is_tail) begin
                    // activate next thread
                    tag_n = head;
                    fs_table_waddr0 = head;
                    fs_table_wdata0.wait_tail = tail;
                    meta_n = fs_table_rdata.meta;
                    state_n = 3'd6;
                end else begin
                    state_n = 1'b0;
                end
            end
        end
        3'd5: begin
            fs_table_raddr = head;
            fs_table_waddr0 = tail;
            fs_table_wdata0.wait_next = tag;
            fs_table_wdata0.wait_tail = tag;
            fs_table_wdata0.is_tail = 1'b0;
            fs_table_wen0 = 4'b0111;
            if (head != tail) begin
                fs_table_waddr1 = head;
                fs_table_wdata1.wait_tail = tag;
                fs_table_wen1 = 4'b0010;
            end
            state_n = 3'd0;
        end
        3'd6: begin
            fs_table_raddr = tag;
            ch0_rden = 1'b1;
            if (!ch0_rd_stall) begin
                tag_last_n = tag;
                key_last_n = key;
                meta_last_n = meta;
                state_n = 3'd7;
            end
        end
        3'd7: begin
            fs_table_raddr = tag;
            if (ch0_rd_valid && (!ch1_insert_stall)) begin
                head_n = fs_table_rdata.wait_next;
                tail_n = fs_table_rdata.wait_tail;
                is_tail_n = fs_table_rdata.is_tail;
                fs_table_raddr = fs_table_rdata.wait_next;
                state_n = 3'd4;
                out_meta_valid_n = 1'b1;
                out_meta_tag_n = tag_last;
            end
        end
    endcase // p_state
end

always_ff @(posedge clk) begin
    if (rst) begin
        state <= 3'd0;
        out_meta_valid <= 'b0;
    end else begin
        state <= state_n;
        out_meta_valid <= out_meta_valid_n;
    end
    opcode <= opcode_n;
    meta <= meta_n;
    meta_last <= meta_last_n;
    head <= head_n;
    tail <= tail_n;
    is_tail <= is_tail_n;
    conflict <= conflict_n;
    fs_table_running <= fs_table_running_n;
    fs_table_hash <= fs_table_hash_n;
    key <= key_n;
    key_last <= key_last_n;
    tag <= tag_n;
    tag_last <= tag_last_n;
    tag_conflict <= tag_conflict_n;
    out_meta_tag <= out_meta_tag_n;
end

always_ff @(posedge clk) begin
    if (fs_table_wen0[0]) fs_table[fs_table_waddr0].is_tail <= fs_table_wdata0.is_tail;
    if (fs_table_wen0[1]) fs_table[fs_table_waddr0].wait_tail <= fs_table_wdata0.wait_tail;
    if (fs_table_wen0[2]) fs_table[fs_table_waddr0].wait_next <= fs_table_wdata0.wait_next;
    if (fs_table_wen0[3]) fs_table[fs_table_waddr0].meta <= fs_table_wdata0.meta;

    if (fs_table_wen1[0]) fs_table[fs_table_waddr1].is_tail <= fs_table_wdata1.is_tail;
    if (fs_table_wen1[1]) fs_table[fs_table_waddr1].wait_tail <= fs_table_wdata1.wait_tail;
    if (fs_table_wen1[2]) fs_table[fs_table_waddr1].wait_next <= fs_table_wdata1.wait_next;
    if (fs_table_wen1[3]) fs_table[fs_table_waddr1].meta <= fs_table_wdata1.meta;

    fs_table_rdata <= fs_table[fs_table_raddr];
end

always @(posedge clk) begin
    if (rst) begin
        path_sel <= 'b0;
    end
    // Stall the pipeline if inserting to full para_q
    else if (!ch1_insert_stall) begin
        // Default value
        out_meta_data.flag <= 'd0;
        if (ch0_rd_ready) path_sel <= 'b0;

        if (ch0_rd_valid) begin
            // Hit, update or push to slow path
            // Check in string matcher if it has payload.
            out_meta_data.ch0_pkt <= meta_last;
            out_meta_data.ch0_bit_map <= ch0_bit_map;
            out_meta_data.flag <= 'd1;
            if (ch0_bit_map != 0) begin
                out_meta_data.ch0_q <= ch0_q;
                path_sel <= 'd1;
            // Miss, insert
            end else begin
                // Insert to para_q, which is bit[4]
                out_meta_data.ch0_q.valid      <= 1;
                out_meta_data.ch0_q.tuple      <= meta_last.tuple;
                out_meta_data.ch0_q.pointer    <= 0;
                out_meta_data.ch0_q.ll_valid   <= 0;
                out_meta_data.ch0_q.slow_cnt   <= 0;
                out_meta_data.ch0_q.addr0      <= key_last[11:0];
                out_meta_data.ch0_q.addr1      <= key_last[23:12];
                out_meta_data.ch0_q.addr2      <= key_last[35:24];
                out_meta_data.ch0_q.addr3      <= key_last[47:36];
                path_sel <= 'd1;
                out_meta_data.flag <= 'd1;

                // SYN's expected seq is special
                if (meta_last.tcp_flags[TCP_SYN]) begin
                    out_meta_data.ch0_q.seq <= meta_last.seq + 1;
                    out_meta_data.ch0_q.last_7_bytes <= {56{1'b1}};
                end
                else begin
                    out_meta_data.ch0_q.seq <= meta_last.seq + meta_last.len;
                    out_meta_data.ch0_q.last_7_bytes <= meta_last.last_7_bytes;
                end
            end
        end
    end else begin
        out_meta_data.flag <= 'd0;
    end
end

always @(posedge clk) begin
    // Match up with the hashtable delay. The
    // stall signal also stalls this pipeline.
    if (!stall) begin
        m0 <= ch0_req_data;
        m1 <= m0;
        m2 <= m1;
        m3 <= m2;
        m4 <= m3;
        m5 <= m4;
        m6 <= m5;
        m7 <= m6;
        ch0_req_tag_vec[0] <= ch0_req_tag;
        ch0_req_tag_vec[1:7] <= ch0_req_tag_vec[0:6];
    end
end

assign h0_tuple_in = ch0_req_data.ch0_pkt.tuple;
assign h1_tuple_in = ch0_req_data.ch0_pkt.tuple;
assign h2_tuple_in = ch0_req_data.ch0_pkt.tuple;
assign h3_tuple_in = ch0_req_data.ch0_pkt.tuple;

assign h0_initval = 32'd0;
assign h1_initval = 32'd1;
assign h2_initval = 32'd2;
assign h3_initval = 32'd3;

// Only accept when the pkt is dequed and the pkt is not f_pkt
assign h0_tuple_in_valid = ch0_req_valid & ch0_req_ready & !f_pkt;
assign h1_tuple_in_valid = ch0_req_valid & ch0_req_ready & !f_pkt;
assign h2_tuple_in_valid = ch0_req_valid & ch0_req_ready & !f_pkt;
assign h3_tuple_in_valid = ch0_req_valid & ch0_req_ready & !f_pkt;

// Stall when: (a) a fast rd/wr happens on the
// same cycle, or (b) inserting to full para_Q.
logic h0_stall;
logic h1_stall;
logic h2_stall;
logic h3_stall;
assign h0_stall = stall;
assign h1_stall = stall;
assign h2_stall = stall;
assign h3_stall = stall;

hash_func hash0 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h0_stall),
    .tuple_in       (h0_tuple_in),
    .initval        (h0_initval),
    .tuple_in_valid (h0_tuple_in_valid),
    .hashed         (h0_hashed),
    .hashed_valid   (h0_hashed_valid)
);
hash_func hash1 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h1_stall),
    .tuple_in       (h1_tuple_in),
    .initval        (h1_initval),
    .tuple_in_valid (h1_tuple_in_valid),
    .hashed         (h1_hashed),
    .hashed_valid   (h1_hashed_valid)
);
hash_func hash2 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h2_stall),
    .tuple_in       (h2_tuple_in),
    .initval        (h2_initval),
    .tuple_in_valid (h2_tuple_in_valid),
    .hashed         (h2_hashed),
    .hashed_valid   (h2_hashed_valid)
);
hash_func hash3 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h3_stall),
    .tuple_in       (h3_tuple_in),
    .initval        (h3_initval),
    .tuple_in_valid (h3_tuple_in_valid),
    .hashed         (h3_hashed),
    .hashed_valid   (h3_hashed_valid)
);

assign ch2_rden = 'b0;
assign ch3_wren = 'b0;
assign ch3_opcode = 'b0;
assign ch3_rel_pkt_cnt = 'b0;

ftCh1Input_t ch1_req_data_r;
logic ch1_req_valid_r;

always_comb begin
    if (ch1_wren) begin
        ch1_opcode_i = ch2_req_data.ch1_opcode;
        ch1_bit_map_i = ch2_req_data.ch1_bit_map;
        ch1_data_i = ch2_req_data.ch1_data;
        ch1_data_i.valid = 1;
    end else begin
        ch1_opcode_i = ch1_req_data_r.ch1_opcode;
        ch1_bit_map_i = ch1_req_data_r.ch1_bit_map;
        ch1_data_i = ch1_req_data_r.ch1_data;
        if (ch1_req_data_r.ch1_opcode == 3) begin
            ch1_data_i.valid = 1'b0;
        end else begin
            ch1_data_i.valid = 1'b1;
        end
    end
end
assign ch1_wren = ch2_req_valid;
assign ch2_req_ready = !ch1_insert_stall;
assign ch1_wren_i = ch1_wren || ch1_req_valid_r;
assign ch1_req_ready = (!ch1_wren) && (!ch1_insert_stall);
always_ff @(posedge clk) begin
    ch1_rep_valid <= ch1_req_valid && ch1_req_ready;
    ch1_rep_data <= 'd0;
    if (ch1_req_ready) begin
        ch1_rep_tag <= ch1_req_tag;
        ch1_req_data_r <= ch1_req_data;
        ch1_req_valid_r <= ch1_req_valid;
    end
end

flow_table flow_table_inst (
    .clk          (clk),
    .rst          (rst),
    .ch0_meta     (ch0_meta),
    .ch0_rden     (ch0_rden),
    .ch0_q        (ch0_q),
    .ch0_rd_valid (ch0_rd_valid),
    .ch0_bit_map  (ch0_bit_map),
    .ch0_rd_stall (ch0_rd_stall),
    .ch1_opcode   (ch1_opcode_i),
    .ch1_bit_map  (ch1_bit_map_i),
    .ch1_wren     (ch1_wren_i),
    .ch1_data     (ch1_data_i),
    .ch1_insert_stall (ch1_insert_stall),
    .ch2_meta     (ch2_meta),
    .ch2_rden     (ch2_rden),
    .ch2_ready    (ch2_ready),
    .ch2_q        (ch2_q),
    .ch2_rd_valid (ch2_rd_valid),
    .ch3_opcode   (ch3_opcode),
    .ch3_wren     (ch3_wren),
    .ch3_ready    (ch3_ready),
    .ch3_data     (ch3_data),
    .ch3_rel_pkt_cnt     (ch3_rel_pkt_cnt)
);

endmodule

module flow_table_wrap (
    input                   clk,
    input                   rst,

    input                   ch0_req_valid,
    input  [TAG_WIDTH-1:0]  ch0_req_tag,
    input  [2:0]            ch0_req_data_ch0_opcode,
    input  [7:0]            ch0_req_data_ch0_pkt_prot,
    input  [31:0]           ch0_req_data_ch0_pkt_tuple_sIP,
    input  [31:0]           ch0_req_data_ch0_pkt_tuple_dIP,
    input  [15:0]           ch0_req_data_ch0_pkt_tuple_sPort,
    input  [15:0]           ch0_req_data_ch0_pkt_tuple_dPort,
    input  [31:0]           ch0_req_data_ch0_pkt_seq,
    input  [15:0]           ch0_req_data_ch0_pkt_len,
    input  [9:0]            ch0_req_data_ch0_pkt_pktID,
    input  [5:0]            ch0_req_data_ch0_pkt_empty,
    input  [4:0]            ch0_req_data_ch0_pkt_flits,
    input  [8:0]            ch0_req_data_ch0_pkt_hdr_len,
    input  [8:0]            ch0_req_data_ch0_pkt_tcp_flags,
    input  [2:0]            ch0_req_data_ch0_pkt_pkt_flags,
    input  [1:0]            ch0_req_data_ch0_pkt_pdu_flag,
    input  [55:0]           ch0_req_data_ch0_pkt_last_7_bytes,
    output                  ch0_req_ready,

    output                  ch0_rep_valid,
    output [TAG_WIDTH-1:0]  ch0_rep_tag,
    output [3:0]            ch0_rep_data_flag,
    output [4:0]            ch0_rep_data_ch0_bit_map,
    output [31:0]           ch0_rep_data_ch0_q_tuple_sIP,
    output [31:0]           ch0_rep_data_ch0_q_tuple_dIP,
    output [15:0]           ch0_rep_data_ch0_q_tuple_sPort,
    output [15:0]           ch0_rep_data_ch0_q_tuple_dPort,
    output [31:0]           ch0_rep_data_ch0_q_seq,
    output [8:0]            ch0_rep_data_ch0_q_pointer,
    output                  ch0_rep_data_ch0_q_ll_valid,
    output [9:0]            ch0_rep_data_ch0_q_slow_cnt,
    output [55:0]           ch0_rep_data_ch0_q_last_7_bytes,
    output [11:0]           ch0_rep_data_ch0_q_addr0,
    output [11:0]           ch0_rep_data_ch0_q_addr1,
    output [11:0]           ch0_rep_data_ch0_q_addr2,
    output [11:0]           ch0_rep_data_ch0_q_addr3,
    output [8:0]            ch0_rep_data_ch0_q_pointer2,
    output [7:0]            ch0_rep_data_ch0_pkt_prot,
    output [31:0]           ch0_rep_data_ch0_pkt_tuple_sIP,
    output [31:0]           ch0_rep_data_ch0_pkt_tuple_dIP,
    output [15:0]           ch0_rep_data_ch0_pkt_tuple_sPort,
    output [15:0]           ch0_rep_data_ch0_pkt_tuple_dPort,
    output [31:0]           ch0_rep_data_ch0_pkt_seq,
    output [15:0]           ch0_rep_data_ch0_pkt_len,
    output [9:0]            ch0_rep_data_ch0_pkt_pktID,
    output [5:0]            ch0_rep_data_ch0_pkt_empty,
    output [4:0]            ch0_rep_data_ch0_pkt_flits,
    output [8:0]            ch0_rep_data_ch0_pkt_hdr_len,
    output [8:0]            ch0_rep_data_ch0_pkt_tcp_flags,
    output [2:0]            ch0_rep_data_ch0_pkt_pkt_flags,
    output [1:0]            ch0_rep_data_ch0_pkt_pdu_flag,
    output [55:0]           ch0_rep_data_ch0_pkt_last_7_bytes,
    input                   ch0_rep_ready,

    input                   ch1_req_valid,
    input  [TAG_WIDTH-1:0]  ch1_req_tag,
    input  [2:0]            ch1_req_data_ch1_opcode,
    input  [4:0]            ch1_req_data_ch1_bit_map,
    input  [31:0]           ch1_req_data_ch1_data_tuple_sIP,
    input  [31:0]           ch1_req_data_ch1_data_tuple_dIP,
    input  [15:0]           ch1_req_data_ch1_data_tuple_sPort,
    input  [15:0]           ch1_req_data_ch1_data_tuple_dPort,
    input  [31:0]           ch1_req_data_ch1_data_seq,
    input  [8:0]            ch1_req_data_ch1_data_pointer,
    input                   ch1_req_data_ch1_data_ll_valid,
    input  [9:0]            ch1_req_data_ch1_data_slow_cnt,
    input  [55:0]           ch1_req_data_ch1_data_last_7_bytes,
    input  [11:0]           ch1_req_data_ch1_data_addr0,
    input  [11:0]           ch1_req_data_ch1_data_addr1,
    input  [11:0]           ch1_req_data_ch1_data_addr2,
    input  [11:0]           ch1_req_data_ch1_data_addr3,
    input  [8:0]            ch1_req_data_ch1_data_pointer2,
    output                  ch1_req_ready,

    output                  ch1_rep_valid,
    output [TAG_WIDTH-1:0]  ch1_rep_tag,
    output [7:0]            ch1_rep_data,
    input                   ch1_rep_ready,

    input                   ch2_req_valid,
    input  [TAG_WIDTH-1:0]  ch2_req_tag,
    input  [2:0]            ch2_req_data_ch1_opcode,
    input  [4:0]            ch2_req_data_ch1_bit_map,
    input  [31:0]           ch2_req_data_ch1_data_tuple_sIP,
    input  [31:0]           ch2_req_data_ch1_data_tuple_dIP,
    input  [15:0]           ch2_req_data_ch1_data_tuple_sPort,
    input  [15:0]           ch2_req_data_ch1_data_tuple_dPort,
    input  [31:0]           ch2_req_data_ch1_data_seq,
    input  [8:0]            ch2_req_data_ch1_data_pointer,
    input                   ch2_req_data_ch1_data_ll_valid,
    input  [9:0]            ch2_req_data_ch1_data_slow_cnt,
    input  [55:0]           ch2_req_data_ch1_data_last_7_bytes,
    input  [11:0]           ch2_req_data_ch1_data_addr0,
    input  [11:0]           ch2_req_data_ch1_data_addr1,
    input  [11:0]           ch2_req_data_ch1_data_addr2,
    input  [11:0]           ch2_req_data_ch1_data_addr3,
    input  [8:0]            ch2_req_data_ch1_data_pointer2,
    output                  ch2_req_ready
);

ftCh0Input_t  ch0_req_data;
ftCh0Output_t ch0_rep_data;
ftCh1Input_t  ch1_req_data;
ftCh1Input_t  ch2_req_data;

assign ch0_req_data.ch0_opcode = ch0_req_data_ch0_opcode;
assign ch0_req_data.ch0_pkt.prot = ch0_req_data_ch0_pkt_prot;
assign ch0_req_data.ch0_pkt.tuple.sIP = ch0_req_data_ch0_pkt_tuple_sIP;
assign ch0_req_data.ch0_pkt.tuple.dIP = ch0_req_data_ch0_pkt_tuple_dIP;
assign ch0_req_data.ch0_pkt.tuple.sPort = ch0_req_data_ch0_pkt_tuple_sPort;
assign ch0_req_data.ch0_pkt.tuple.dPort = ch0_req_data_ch0_pkt_tuple_dPort;
assign ch0_req_data.ch0_pkt.seq = ch0_req_data_ch0_pkt_seq;
assign ch0_req_data.ch0_pkt.len = ch0_req_data_ch0_pkt_len;
assign ch0_req_data.ch0_pkt.pktID = ch0_req_data_ch0_pkt_pktID;
assign ch0_req_data.ch0_pkt.empty = ch0_req_data_ch0_pkt_empty;
assign ch0_req_data.ch0_pkt.flits = ch0_req_data_ch0_pkt_flits;
assign ch0_req_data.ch0_pkt.hdr_len = ch0_req_data_ch0_pkt_hdr_len;
assign ch0_req_data.ch0_pkt.tcp_flags = ch0_req_data_ch0_pkt_tcp_flags;
assign ch0_req_data.ch0_pkt.pkt_flags = ch0_req_data_ch0_pkt_pkt_flags;
assign ch0_req_data.ch0_pkt.pdu_flag = ch0_req_data_ch0_pkt_pdu_flag;
assign ch0_req_data.ch0_pkt.last_7_bytes = ch0_req_data_ch0_pkt_last_7_bytes;

assign ch0_rep_data_flag = ch0_rep_data.flag;
assign ch0_rep_data_ch0_bit_map = ch0_rep_data.ch0_bit_map;
assign ch0_rep_data_ch0_q_tuple_sIP = ch0_rep_data.ch0_q.tuple.sIP;
assign ch0_rep_data_ch0_q_tuple_dIP = ch0_rep_data.ch0_q.tuple.dIP;
assign ch0_rep_data_ch0_q_tuple_sPort = ch0_rep_data.ch0_q.tuple.sPort;
assign ch0_rep_data_ch0_q_tuple_dPort = ch0_rep_data.ch0_q.tuple.dPort;
assign ch0_rep_data_ch0_q_seq = ch0_rep_data.ch0_q.seq;
assign ch0_rep_data_ch0_q_pointer = ch0_rep_data.ch0_q.pointer;
assign ch0_rep_data_ch0_q_ll_valid = ch0_rep_data.ch0_q.ll_valid;
assign ch0_rep_data_ch0_q_slow_cnt = ch0_rep_data.ch0_q.slow_cnt;
assign ch0_rep_data_ch0_q_last_7_bytes = ch0_rep_data.ch0_q.last_7_bytes;
assign ch0_rep_data_ch0_q_addr0 = ch0_rep_data.ch0_q.addr0;
assign ch0_rep_data_ch0_q_addr1 = ch0_rep_data.ch0_q.addr1;
assign ch0_rep_data_ch0_q_addr2 = ch0_rep_data.ch0_q.addr2;
assign ch0_rep_data_ch0_q_addr3 = ch0_rep_data.ch0_q.addr3;
assign ch0_rep_data_ch0_q_pointer2 = ch0_rep_data.ch0_q.pointer2;
assign ch0_rep_data_ch0_pkt_prot = ch0_rep_data.ch0_pkt.prot;
assign ch0_rep_data_ch0_pkt_tuple_sIP = ch0_rep_data.ch0_pkt.tuple.sIP;
assign ch0_rep_data_ch0_pkt_tuple_dIP = ch0_rep_data.ch0_pkt.tuple.dIP;
assign ch0_rep_data_ch0_pkt_tuple_sPort = ch0_rep_data.ch0_pkt.tuple.sPort;
assign ch0_rep_data_ch0_pkt_tuple_dPort = ch0_rep_data.ch0_pkt.tuple.dPort;
assign ch0_rep_data_ch0_pkt_seq = ch0_rep_data.ch0_pkt.seq;
assign ch0_rep_data_ch0_pkt_len = ch0_rep_data.ch0_pkt.len;
assign ch0_rep_data_ch0_pkt_pktID = ch0_rep_data.ch0_pkt.pktID;
assign ch0_rep_data_ch0_pkt_empty = ch0_rep_data.ch0_pkt.empty;
assign ch0_rep_data_ch0_pkt_flits = ch0_rep_data.ch0_pkt.flits;
assign ch0_rep_data_ch0_pkt_hdr_len = ch0_rep_data.ch0_pkt.hdr_len;
assign ch0_rep_data_ch0_pkt_tcp_flags = ch0_rep_data.ch0_pkt.tcp_flags;
assign ch0_rep_data_ch0_pkt_pkt_flags = ch0_rep_data.ch0_pkt.pkt_flags;
assign ch0_rep_data_ch0_pkt_pdu_flag = ch0_rep_data.ch0_pkt.pdu_flag;
assign ch0_rep_data_ch0_pkt_last_7_bytes = ch0_rep_data.ch0_pkt.last_7_bytes;

assign ch1_req_data.ch1_opcode = ch1_req_data_ch1_opcode;
assign ch1_req_data.ch1_bit_map = ch1_req_data_ch1_bit_map;
assign ch1_req_data.ch1_data.tuple.sIP = ch1_req_data_ch1_data_tuple_sIP;
assign ch1_req_data.ch1_data.tuple.dIP = ch1_req_data_ch1_data_tuple_dIP;
assign ch1_req_data.ch1_data.tuple.sPort = ch1_req_data_ch1_data_tuple_sPort;
assign ch1_req_data.ch1_data.tuple.dPort = ch1_req_data_ch1_data_tuple_dPort;
assign ch1_req_data.ch1_data.seq = ch1_req_data_ch1_data_seq;
assign ch1_req_data.ch1_data.pointer = ch1_req_data_ch1_data_pointer;
assign ch1_req_data.ch1_data.ll_valid = ch1_req_data_ch1_data_ll_valid;
assign ch1_req_data.ch1_data.slow_cnt = ch1_req_data_ch1_data_slow_cnt;
assign ch1_req_data.ch1_data.last_7_bytes = ch1_req_data_ch1_data_last_7_bytes;
assign ch1_req_data.ch1_data.addr0 = ch1_req_data_ch1_data_addr0;
assign ch1_req_data.ch1_data.addr1 = ch1_req_data_ch1_data_addr1;
assign ch1_req_data.ch1_data.addr2 = ch1_req_data_ch1_data_addr2;
assign ch1_req_data.ch1_data.addr3 = ch1_req_data_ch1_data_addr3;
assign ch1_req_data.ch1_data.pointer2 = ch1_req_data_ch1_data_pointer2;

assign ch2_req_data.ch1_opcode = ch2_req_data_ch1_opcode;
assign ch2_req_data.ch1_bit_map = ch2_req_data_ch1_bit_map;
assign ch2_req_data.ch1_data.tuple.sIP = ch2_req_data_ch1_data_tuple_sIP;
assign ch2_req_data.ch1_data.tuple.dIP = ch2_req_data_ch1_data_tuple_dIP;
assign ch2_req_data.ch1_data.tuple.sPort = ch2_req_data_ch1_data_tuple_sPort;
assign ch2_req_data.ch1_data.tuple.dPort = ch2_req_data_ch1_data_tuple_dPort;
assign ch2_req_data.ch1_data.seq = ch2_req_data_ch1_data_seq;
assign ch2_req_data.ch1_data.pointer = ch2_req_data_ch1_data_pointer;
assign ch2_req_data.ch1_data.ll_valid = ch2_req_data_ch1_data_ll_valid;
assign ch2_req_data.ch1_data.slow_cnt = ch2_req_data_ch1_data_slow_cnt;
assign ch2_req_data.ch1_data.last_7_bytes = ch2_req_data_ch1_data_last_7_bytes;
assign ch2_req_data.ch1_data.addr0 = ch2_req_data_ch1_data_addr0;
assign ch2_req_data.ch1_data.addr1 = ch2_req_data_ch1_data_addr1;
assign ch2_req_data.ch1_data.addr2 = ch2_req_data_ch1_data_addr2;
assign ch2_req_data.ch1_data.addr3 = ch2_req_data_ch1_data_addr3;
assign ch2_req_data.ch1_data.pointer2 = ch2_req_data_ch1_data_pointer2;


flowTableV inst(.*);


endmodule