`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2023 10:44:27
// Design Name: 
// Module Name: testbench_w_scb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


class transaction;
  rand bit [3:0]a;
  rand bit [3:0]b;
  bit [7:0]c;
  
  function void display(string name);
    $display("------------------------");
    $display("- %s ",name);
    $display("-------------------------");
    $display("- a = %0d, b = %0d",a,b);
    $display("- c = %0d",c);
    $display("-------------------------");
  endfunction
  
endclass

class generator;

  rand transaction t1;
  
  mailbox gen2driv;
  
  event ended;
  
  int repeat_count;
  
  function new(mailbox gen2driv);
    this.gen2driv=gen2driv;
  endfunction
  
  task main();
    repeat(repeat_count)
      begin
        t1=new();
        if(!t1.randomize()) $fatal("Generator: randomization of transaction failed");
        gen2driv.put(t1);
      end
    ->ended;
  endtask
  
endclass


interface intf(input logic clk,reset);
  logic valid;
  logic [3:0]a;
  logic [3:0]b;
  logic [7:0]c;
endinterface


class driver;
  
  virtual intf vif;

  //creating mailbox handle
  mailbox gen2driv;

  int no_transactions;
  //constructor
  function new(virtual intf vif,mailbox gen2driv);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handle from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  task reset;
    wait(vif.reset);
    $display("[ DRIVER ] ----- Reset Started -----");
    vif.a <= 0;
    vif.b <= 0;
    vif.valid <= 0;
    wait(!vif.reset);
    $display("[ DRIVER ] ----- Reset Ended   -----");
  endtask
	
  //drive the transaction items to interface signals
  task main();
    forever begin
      transaction trans;
      gen2driv.get(trans);
      @(posedge vif.clk);
      vif.valid <= 1;
      vif.a     <= trans.a;
      vif.b     <= trans.b;
      @(posedge vif.clk);
      vif.valid <= 0;
      trans.c   <= vif.c;
      @(posedge vif.clk);
      trans.display("[ Driver ]");
      no_transactions++;
    end
  endtask
  
endclass

class monitor;
  virtual intf vif;
  
  mailbox mon2scb;
  function new(virtual intf vif,mailbox mon2scb);
    this.vif=vif;
    this.mon2scb=mon2scb;
  endfunction
  
  task main;
    forever begin
      transaction trans;
      trans = new();
      @(posedge vif.clk);
      wait(vif.valid);
      trans.a   = vif.a;
      trans.b   = vif.b;
      @(posedge vif.clk);
      trans.c   = vif.c;
      @(posedge vif.clk);
      mon2scb.put(trans);
      trans.display("[ Monitor ]");
    end
  endtask
  
endclass

class scoreboard;
   
  //creating mailbox handle
  mailbox mon2scb;
  
  //used to count the number of transactions
  int no_transactions;
  
  //constructor
  function new(mailbox mon2scb);
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Compares the Actual result with the expected result
  task main;
    transaction trans;
    forever begin
      mon2scb.get(trans);
        if((trans.a+trans.b) == trans.c)
          $display("Result is as Expected");
        else
          $error("Wrong Result.\n\tExpeced: %0d Actual: %0d",(trans.a+trans.b),trans.c);
        no_transactions++;
      trans.display("[ Scoreboard ]");
    end
  endtask
  
endclass


class environment;
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;
  
  mailbox mon2scb;
  mailbox gen2driv;
  
  virtual intf vif;
  
  function new(virtual intf vif);
    this.vif=vif;
    gen2driv=new();
    mon2scb=new();
    
    gen=new(gen2driv);
    driv=new(vif,gen2driv);
    mon=new(vif,mon2scb);
    scb=new(mon2scb);
    
  endfunction
  
  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork 
      gen.main();
      driv.main();
      mon.main();
      scb.main();
    join_any
  endtask
  
  task post_test();
    wait(gen.ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
    wait(gen.repeat_count == scb.no_transactions);
  endtask 
  
  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask
  
endclass

program test(intf i1);
  environment env;
  
  initial begin
    env=new(i1);
    env.gen.repeat_count=10;
    env.run;
  end
  
endprogram

module tb_top;
  bit clk,reset;
  
  always begin
    #5 clk=~clk;
  end
  
  initial begin
    clk=0;
    reset=1;
    #10
    reset=0;
  end
  intf i1(clk,reset);
  test t1(i1);
  
  adder a1(i1.clk,i1.reset,i1.a,i1.b,i1.c);
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
