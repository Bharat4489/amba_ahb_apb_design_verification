    class my_test extends uvm_test;
        `uvm_component_utils(my_test)

        ahb_env env;

        function new(string name="my_test", uvm_component parent=null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ahb_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            ahb_base_sequence seq;
            // my_vseq vseq;

            `uvm_info("MY_TEST", "RAISING OBJECTION", UVM_MEDIUM)
            phase.raise_objection(this);

            seq = ahb_base_sequence::type_id::create("seq");
            `uvm_info("MY_TEST", "STARTING SEQUENCE", UVM_MEDIUM)
            seq.start(env.m_ahb_agent[0].m_ahb_sequencer);

            #100;
            `uvm_info("MY_TEST", "DROPPING OBJECTION", UVM_MEDIUM)
            phase.drop_objection(this);
        endtask
    endclass
