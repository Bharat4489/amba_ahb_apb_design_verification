
    class my_directed_test extends uvm_test;
        `uvm_component_utils(my_directed_test)

        ahb_env env;

        function new(string name="my_directed_test", uvm_component parent=null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ahb_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            multiple_write_read_seq dir_seq;
            `uvm_info("my_directed_test", "RAISING OBJECTION", UVM_MEDIUM)
            phase.raise_objection(this);

            dir_seq = multiple_write_read_seq::type_id::create("dir_seq");
            `uvm_info("my_directed_test", "STARTING dir_seqUENCE", UVM_MEDIUM)
            dir_seq.start(env.m_ahb_agent.m_ahb_sequencer);

            #100;
            `uvm_info("my_directed_test", "DROPPING OBJECTION", UVM_MEDIUM)
            phase.drop_objection(this);
        endtask
    endclass
