class ahb_env extends uvm_env;
    `uvm_component_utils(ahb_env)

    ahb_master_agent m_ahb_agent[NO_OF_MASTERS];
    ahb_agent_cfg m_agent_cfg[NO_OF_MASTERS];

    ahb_master_virtual_sequencer vseqr;

    uvm_analysis_export #(ahb_seq_item) anaylsis_export;                    //declaring anaylsis_export
    ahb_scoreboard m_sb;

    function new(string name = "ahb_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
endclass : ahb_env

////////////////////////////
//BUILD PHASE
function void ahb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //configuring each agent
    foreach (m_ahb_agent[i]) begin
        m_agent_cfg[i]              =   ahb_agent_cfg::type_id::create($sformatf("m_agent_cfg_%0d",i));
        m_agent_cfg[i].master_id    =   (i==0)?CPU_MASTER:DMA_MASTER;
        m_agent_cfg[i].is_active    =   UVM_ACTIVE;


    //setting agent config inside config database
    uvm_config_db#(ahb_agent_cfg)::set(this, $sformatf("m_ahb_agent[%0d]*",i), "ahb_agent_cfg", m_agent_cfg[i]);

    //creating agents
    m_ahb_agent[i] = ahb_master_agent::type_id::create($sformatf("m_ahb_agent[%0d]",i),this);

    end

    //creating vseqr to save seqs
    vseqr = ahb_master_virtual_sequencer::type_id::create("vseqr", this);

    //creating scoreboard and registering in factory
    m_sb = ahb_scoreboard::type_id::create("m_sb", this);
    //creating anaylsis_export
    anaylsis_export = new("anaylsis_export", this);

endfunction

////////////////////////////
//CONNECT PHASE
function void ahb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    foreach (m_ahb_agent[i]) begin
        if (m_ahb_agent[i].is_active == UVM_ACTIVE)begin
            vseqr.m_ahb_seqr.push_back(m_ahb_agent[i].m_ahb_sequencer);
        end

        m_ahb_agent[i].ap.connect(this.anaylsis_export);    // Agent → Env export
    end

    this.anaylsis_export.connect(m_sb.analysis_imp);      // Env export → Scoreboard imp
/*
m_ahb_agent.ap.connect(ahb_env.anaylsis_export);

as anaylsis_export is instance member so should be used with "this".
"this" will connect it to proper hierarchy by searching instance name in uvm factory
*/
endfunction


task ahb_env::run_phase(uvm_phase phase);
    uvm_top.print_topology;
endtask : run_phase
