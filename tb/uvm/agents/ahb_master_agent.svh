class ahb_master_agent extends uvm_agent;
    `uvm_component_utils(ahb_master_agent)

    ahb_master_sequencer m_ahb_sequencer;
    ahb_master_driver m_ahb_driver;

    function new(string name = "ahb_master_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass : ahb_master_agent


function void ahb_master_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (is_active==UVM_ACTIVE) begin
        m_ahb_sequencer = ahb_master_sequencer::type_id::create("m_ahb_sequencer", this);
        m_ahb_driver = ahb_master_driver::type_id::create("m_ahb_driver", this);    
    end
endfunction

function void ahb_master_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active==UVM_ACTIVE) begin
        m_ahb_driver.seq_item_port.connect(m_ahb_sequencer.seq_item_export);
    end
endfunction
