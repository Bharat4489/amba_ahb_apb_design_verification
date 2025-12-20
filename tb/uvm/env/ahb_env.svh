//UNCHECKED

class ahb_env extends uvm_env;
    `uvm_component_utils(ahb_env)

    ahb_master_agent m_ahb_agent;
    uvm_analysis_export #(ahb_seq_item) anaylsis_export;                    //declaring anaylsis_export
    ahb_scoreboard m_sb;

    function new(string name = "ahb_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass : ahb_env

function void ahb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_ahb_agent = ahb_master_agent::type_id::create("m_ahb_agent", this);
    m_sb = ahb_scoreboard::type_id::create("m_sb", this);                //creating scoreboard and registering in factory
    anaylsis_export = new("anaylsis_export", this);                      //creating anaylsis_export

endfunction

function void ahb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_ahb_agent.ap.connect(this.anaylsis_export);       // Agent → Env export
    this.anaylsis_export.connect(m_sb.analysis_imp);      // Env export → Scoreboard imp
/*
m_ahb_agent.ap.connect(ahb_env.anaylsis_export);

as anaylsis_export is instance member so should be used with this.
"this" will connect it to proper hierarchy by searching instance name in uvm factory
*/
endfunction
