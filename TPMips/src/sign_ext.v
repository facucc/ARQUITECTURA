module sign_ext
    #(
        parameter NB_EXTEND = 32,
        parameter NB_UNEXTEND = 16
    )
    (
        input wire [NB_UNEXTEND-1:0] unextend_i,
        output wire [NB_EXTEND-1:0] extended_o
    );

    assign extended_o = {{16{unextend_i[15]}}, unextend_i};

    
endmodule