
class my_directed_test extends uvm_test;
    `uvm_component_utils(my_directed_test)

    ahb_env env;

    extern function new(string name="my_directed_test", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass

    // -------------------------
    // NEW
function my_directed_test::new(string name="my_directed_test", uvm_component parent=null);
    super.new(name, parent);
endfunction : new

    // -------------------------
    // BUILD PHASE
function void my_directed_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ahb_env::type_id::create("env", this);
endfunction : build_phase

    // -------------------------
    // RUN PHASE
task my_directed_test::run_phase(uvm_phase phase);
    multiple_write_read_seq dir_seq1;
    ahb_basic_burst_seq     dir_seq2;
    ahb_incr_burst_seq      dir_seq3;
    ahb_wrap_burst_seq      dir_seq4;

    `uvm_info("my_directed_test", "RAISING OBJECTION", UVM_MEDIUM)
    phase.raise_objection(this);

    // -------------------------
    // STARTING multiple_write_read_seq
    // -------------------------
    dir_seq1 = multiple_write_read_seq::type_id::create("dir_seq1");
    `uvm_info("my_directed_test", "STARTING multiple_write_read_seq", UVM_MEDIUM)
    dir_seq1.start(env.m_ahb_agent.m_ahb_sequencer);

    // -------------------------
    // STARTING ahb_basic_burst_seq
    // -------------------------
    dir_seq2 = ahb_basic_burst_seq::type_id::create("dir_seq2");
    `uvm_info("my_directed_test", "STARTING ahb_basic_burst_seq", UVM_MEDIUM)
    dir_seq2.start(env.m_ahb_agent.m_ahb_sequencer);  

    // -------------------------
    // STARTING ahb_incr_burst_seq
    // -------------------------
    dir_seq3 = ahb_incr_burst_seq::type_id::create("dir_seq3");
    `uvm_info("my_directed_test", "STARTING ahb_incr_burst_seq", UVM_MEDIUM)
    dir_seq3.start(env.m_ahb_agent.m_ahb_sequencer);                       

    // -------------------------
    // STARTING ahb_wrap_burst_seq
    // -------------------------
    dir_seq4 = ahb_incr_burst_seq::type_id::create("dir_seq4");
    `uvm_info("my_directed_test", "STARTING ahb_wrap_burst_seq", UVM_MEDIUM)
    dir_seq4.start(env.m_ahb_agent.m_ahb_sequencer); 

    `uvm_info("my_directed_test", "DROPPING OBJECTION", UVM_MEDIUM)
    phase.drop_objection(this);
endtask