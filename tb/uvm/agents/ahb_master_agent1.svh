class ahb_master_agent extends uvm_agent;
    `uvm_component_utils(ahb_master_agent)

    ahb_master_sequencer m_ahb_sequencer;
    ahb_master_driver m_ahb_driver;
    ahb_master_monitor m_ahb_monitor;

    uvm_analysis_port #(ahb_seq_item) ap;       //analysis port declared inside the agent

    function new(string name = "ahb_master_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    ahb_agent_cfg m_agent_cfg;

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass : ahb_master_agent

////////////////////////////
//BUILD PHASE
function void ahb_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);

    if(!uvm_config_db#(ahb_agent_cfg)::get(this, "", "ahb_agent_cfg", m_agent_cfg))
        `uvm_fatal("NO_CFG", "unable to get agent cfg, have you set it?")

    m_ahb_monitor = ahb_master_monitor::type_id::create("m_ahb_monitor", this); //monitor is always created irrespectiVE of is_active

    if (m_agent_cfg.is_active==UVM_ACTIVE) begin
        m_ahb_sequencer = ahb_master_sequencer::type_id::create("m_ahb_sequencer", this);
        m_ahb_driver = ahb_master_driver::type_id::create("m_ahb_driver", this);
    end
endfunction

////////////////////////////
//CONNECT PHASE - connect monitor analysis port to agent analysis port
function void ahb_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_ahb_monitor.ap.connect(ap);
    if (is_active==UVM_ACTIVE) begin
        m_ahb_driver.seq_item_port.connect(m_ahb_sequencer.seq_item_export);
    end
endfunction

////////////////////////////
//RUN PHASE- not using since not doing anything
task  ahb_master_agent::run_phase(uvm_phase phase);
    //uvm_top.print_topology;         //print topology in log file
endtask //ahb_master_agent::run_phase
