`timescale 1ns/10ps
`define CYCLE      16.2  
`define End_CYCLE  1000000
`define PAT        "../sim/univ.txt"          
`include "./geofence.v"

module testfixture();
integer fd;
integer objnum;
integer obj_isin;
integer charcount;
integer pass=0;
integer fail=0;
string line;
reg [5:0] npoint;
reg signed [10:0] X;
reg signed [10:0] Y;

reg check = 1;                        //  0 => no print  1 => print pattern  
reg clk = 0;
wire valid;
reg reset =0;
wire is_inside;
geofence u_geofence(.clk(clk),
        .reset(reset),
        .X(X),
        .Y(Y),
        .valid(valid),
        .is_inside(is_inside));

`ifdef SDF
    initial $sdf_annotate(`SDFFILE, u_geofence);
`endif

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
    $fsdbDumpfile("geofence.fsdb");
    $fsdbDumpvars();
    $fsdbDumpMDA;
end


initial begin
    $display("----------------------");
    $display("-- Simulation Start --");
    $display("----------------------");
    @(posedge clk);  #2 reset = 1'b1; 
    #(`CYCLE*2);  
    @(posedge clk);  #2  reset = 1'b0;
end

reg [22:0] cycle=0;

always @(posedge clk) begin
    cycle=cycle+1;
    if (cycle > `End_CYCLE) begin
        $display("--------------------------------------------------");
        $display("-- Failed waiting valid signal, Simulation STOP --");
        $display("--------------------------------------------------");
        $fclose(fd);
        $finish;
    end
end

initial begin
    fd = $fopen(`PAT,"r");
    if (fd == 0) begin
        $display ("pattern handle null");
        $finish;
    end
end

reg  valid_reg;
always @(posedge clk) begin
    valid_reg = valid;
end
reg wait_valid;
reg get_inside;
integer ap_num;

always @(posedge clk ) begin
    if (reset) begin
        wait_valid=0;
    end
    else begin
        if(wait_valid == 0) begin
            if(ap_num ==5) wait_valid =1;
        end
        else begin
            if (valid ==1) begin
                wait_valid=0;
                get_inside=is_inside;
                if(get_inside == obj_isin) begin
                    pass = pass +1;
                    if(check)$display("Object%0d: Golden/Return => %0d/%d, PASS\n",objnum,obj_isin,get_inside);
                end
                else begin
                    fail = fail +1;
                    if(check)$display("Object%0d: Golden/Return => %0d/%d, FAIL\n",objnum,obj_isin,get_inside);
                end
            end
        end
    end
end

always @(negedge clk ) begin
    if (reset) begin
        X=0;
        Y=0;
        ap_num = 0;
    end 
    else begin
        if (!$feof(fd)) begin
            if(wait_valid ==0) begin
                charcount = $fgets (line, fd);
                if(charcount != 0) begin
                    while( line.substr(1, 2) == "//") charcount = $fgets (line, fd);
                    if( line.substr(0, 5) == "object") begin
                        charcount = $sscanf(line, "object %d %d",objnum,obj_isin);
                        if((obj_isin == 1)&check)
									$display ("Scenario%0d(in):      X     Y",objnum);
                        else
                            if(check)$display ("Scenario%0d(out):     X     Y",objnum);
                        ap_num=0;
                        charcount = $fgets (line, fd);
                        charcount = $sscanf(line, "%d %d",X,Y);
                        if(check)$display("        Target:  %5d, %5d", X ,Y);
                    end 
                    else begin
                        ap_num = ap_num+1;
                        charcount = $sscanf(line, "%d %d",X,Y);
                        if(check)$display("     Receiver%1d:  %5d, %5d",ap_num, X ,Y);
                    end
                end
            end
        end //if (!$feof(fd)) begin
        else begin
             $fclose(fd);
            
            if(fail==0)
            begin
            $display("\n⣿⣿⣿⣿⣿⣿⠿⢋⣥⣴⣶⣶⣶⣬⣙⠻⠟⣋⣭⣭⣭⣭⡙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⡿⢋⣴⣿⣿⠿⢟⣛⣛⣛⠿⢷⡹⣿⣿⣿⣿⣿⣿⣆⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⡿⢁⣾⣿⣿⣴⣿⣿⣿⣿⠿⠿⠷⠥⠱⣶⣶⣶⣶⡶⠮⠤⣌⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⡿⢛⡁⣾⣿⣿⣿⡿⢟⡫⢕⣪⡭⠥⢭⣭⣉⡂⣉⡒⣤⡭⡉⠩⣥⣰⠂⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⡟⢠⣿⣱⣿⣿⣿⣏⣛⢲⣾⣿⠃⠄⠐⠈⣿⣿⣿⣿⣿⣿⠄⠁⠃⢸⣿⣿⡧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⢠⣿⣿⣿⣿⣿⣿⣿⣿⣇⣊⠙⠳⠤⠤⠾⣟⠛⠍⣹⣛⣛⣢⣀⣠⣛⡯⢉⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡶⠶⢒⣠⣼⣿⣿⣛⠻⠛⢛⣛⠉⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⣿⣿⣿⡿⢛⡛⢿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿       Simulation Pass !!!   ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⣿⣿⣿⠸⣿⡻⢷⣍⣛⠻⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢇⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⣿⣿⣿⣷⣝⠻⠶⣬⣍⣛⣛⠓⠶⠶⠶⠤⠬⠭⠤⠶⠶⠞⠛⣡⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣬⣭⣍⣙⣛⣛⣛⠛⠛⠛⠿⠿⠿⠛⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣦⣈⠉⢛⠻⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⣁⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣶⣮⣭⣁⣒⣒⣒⠂⠠⠬⠭⠭⠭⢀⣀⣠⣄⡘⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n");
            end
            else
            begin
            $display("\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣟⣿⣟⡿⠏⠛⠛⠛⠛⢛⣛⣛⡛⡙⠛⠻⠯⠿⠟⢯⣿⣿⣯⣿⣿⣻⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣯⣿⡿⢉⣴⣿⢟⡾⢛⡿⠿⢶⢶⣾⣿⣿⣿⣿⣭⣭⣲⢶⣶⢭⣙⠻⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣻⡽⣀⡫⣽⣿⣿⣻⠟⠀⠀⠀⠑⢽⢿⢟⢿⣿⠏⠁⠀⠙⠿⣷⣝⢷⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⠋⣰⢟⠛⢝⣺⡭⣃⡀👁⠀⠀⣨⣗⣾⣷⢘⣄👁 ⣀⣔⢺⣟⢿⣥⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿");
            $display("⡏⣵⡎⣵⣱⣶⡀⠈⠙⢯⣳⣶⣶⢂⣼⠹⠿⠛⣿⣦⢳⣄⣶⡺⠝⠈⠁⢰⠏⣷⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⡀⢿⣿⣄⣿⢿⣧⡀⠀⠀⠀⠀⠙⠛⣛⡗⣞⣉⡉⢉⣈⢭⡄⠀⠀⠀⠀⢨⣾⡹⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣷⣌⠿⣼⣜⣿⣿⡽⣦⠀⠀⠀⣼⣷⡸⣰⡎⢋⣾⣷⢣⣿⣇⠀⠀⠀⠀⣸⡏⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿            Simulation Fail !!!     ⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣦⠙⣿⡿⣿⣿⣟⣷⣄⠀⠈⠉⠁⠛⠃⠘⠿⠿⠈⠛⠉⠀⠀⠀⠀⢿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣧⣘⠿⡽⣿⣿⣮⣳⣱⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠉⣷⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⢿⣽⣿⣷⣌⠙⢿⣿⣿⣿⣷⣝⢦⡀⠀⠐⣆⢷⣿⡎⣷⠀⠀⠀⠀⢠⡟⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣿⣿⡿⣿⣻⣿⣶⣮⣭⡘⠻⢿⣷⡺⣴⣦⣥⣍⣈⣁⣀⠈⠤⣖⣶⣾⣵⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣷⣿⣿⣿⣿⡿⣿⣻⣿⣿⣷⣦⣌⣙⣒⡶⠾⠿⣿⣿⠿⠿⠿⣻⡽⠛⢟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣯⣿⣷⣿⣟⣿⣿⣿⣿⣻⣿⣻⣿⣿⣿⣿⣿⣷⣶⣤⣤⣭⣥⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
            $display("⣿⣿⣟⣿⣯⣿⣿⣿⢿⣽⣾⣿⣿⢿⣿⣻⣽⣿⡿⣟⣿⣿⣿⡿⣿⣿⣿⣿⢿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n");
            end
        $finish;
        end
    end
end
endmodule
