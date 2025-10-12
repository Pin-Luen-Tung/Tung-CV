  reg ack;

  task I2C_MACRO;
		parameter OPEN_NAME="i2c.tbl";
		parameter OPEN_SIZE=8196;

		parameter I2C_Start=0;
		parameter I2C_DevAddr=1;
		parameter I2C_SubAddr=2;
		parameter I2C_Write=3;
		parameter I2C_Read=4;
		parameter I2C_Stop=5;
		parameter I2C_Finish=6;

		reg [10:0] i2c_buf [0:OPEN_SIZE-1];
		reg [10:0] i2c_command;
		reg ibreak;
		integer 	 ic;
		begin
			$readmemh(OPEN_SIZE,i2c_buf);
			ibreak=0;
			for (ic=0;(ibreak==0);ic=ic+1)
				begin
					i2c_command = i2c_buf[ic];
					case(i2c_command[10:8])
						I2C_Start:	I2C_START;
						I2C_DevAddr:	I2C_WRITE_DEVICE(i2c_command[7:0]);
						I2C_SubAddr:	I2C_WRITE_SUBADDR(i2c_command[7:0]);
						I2C_Write:		I2C_WRITE_BYTE(i2c_command[7:0]);
						I2C_Read:			I2C_READ_BYTE(i2c_command[7:0]);
						I2C_Stop:			I2C_STOP;
						I2C_Finish:		ibreak=1;
					endcase
				end
		end
	endtask

	task I2C_RX_BYTE;
		output [7:0] rx;
		reg [7:0] i;
		begin
			#(`DELAY) i2c_dir = 0;
			for (i=0;i<8;i=i+1)
				begin
					#(`DELAY) i2c_scl = 0;
					#(`DELAY) i2c_scl = 1;
					#(`DELAY) rx[7-i] = SDA;
					#(`DELAY) i2c_scl = 0;
				end
			$display("read BYTE=%h",rx);
		end
	endtask

	task I2C_TX_BYTE;
		input [7:0] tx;
		reg [7:0] i;
		begin
			#(`DELAY) i2c_dir=1;
			for (i=0;i<8;i=i+1)
				begin
					#(`DELAY) i2c_scl=0;
					#(`DELAY) sda_in = tx[7-i];
					#(`DELAY) i2c_scl=1;
					#(`DELAY) i2c_scl=0;
				end
		end
	endtask

	task I2C_START;
		begin
			work_flag = 0 ;
			#(`DELAY) i2c_dir=1;
			#(`DELAY) sda_in =1;	// i2c start
			#(`DELAY) i2c_scl=1;
			#(`DELAY) sda_in =0;
			#(`DELAY) work_flag = 1 ;
		end
	endtask

	task I2C_STOP;
		begin
			work_flag = 0;
			#(`DELAY) i2c_dir= 1;
			#(`DELAY) sda_in = 0;
			#(`DELAY) i2c_scl= 1;
			#(`DELAY) sda_in = 1;
		end
	endtask

	task I2C_SLAVE_ACK;
		begin
			#(`DELAY) i2c_dir=0;	// wait	slave ackownledge
			#(`DELAY) i2c_scl=1;
			#(`DELAY) ack = SDA; slave_ack_flag = 1 ;
			#(`DELAY) i2c_scl=0; slave_ack_flag = 0 ;
			#(`DELAY) i2c_dir=1;
		end
	endtask

	task I2C_MASTER_ACK;
		input in;
		begin
			#(`DELAY) i2c_dir=1;		// send ack to slave
			#(`DELAY) i2c_scl=0;
			#(`DELAY) sda_in=in;  
			#(`DELAY) i2c_scl=1; master_ack_flag = 1 ;
			#(`DELAY) i2c_scl=0; master_ack_flag = 0 ;
		end
	endtask


	task I2C_WRITE_DEVICE;
		input [7:0] dev;
		begin
			I2C_TX_BYTE(dev);
			I2C_SLAVE_ACK;
			if (ack==`BIT0)
				$display ("device ID=%h ack",dev);
			else
				$display ("device ID=%h not ack",dev);
		end
	endtask

	task I2C_WRITE_SUBADDR;
		input [7:0] dev;
		begin
			I2C_TX_BYTE(dev);
			I2C_SLAVE_ACK;
			if (ack==`BIT0)
				$display ("sub addr =%h ack",dev);
			else
				$display ("sub addr =%h not ack",dev);
		end
	endtask

  task I2C_WRITE_ADDR;
		input [7:0] dev;
		begin
			I2C_TX_BYTE(dev);
			I2C_SLAVE_ACK;
			if (ack==`BIT0)
				$display ("addr =%h ack",dev);
			else
				$display ("addr =%h not ack",dev);
		end
	endtask

	task I2C_WRITE_BYTE;
		input [7:0] dev;
		begin
			I2C_TX_BYTE(dev);
			I2C_SLAVE_ACK;
			if (ack==`BIT0)
				$display ("write =%h ack",dev);
			else
				$display ("write =%h not ack",dev);
		end
	endtask

	task I2C_WRITE_WORD;
		input [15:0] dev;
		begin
			I2C_TX_BYTE(dev[7:0]);
			I2C_SLAVE_ACK;
			if (ack==`BIT0)
				begin
					I2C_TX_BYTE(dev[15:8]);
					I2C_SLAVE_ACK;
				end
			if (ack==`BIT0)
				$display ("write.=%h ack",dev);
			else
				$display ("write.=%h not ack",dev);
		end
	endtask

	task I2C_WRITE_TRIP;
		input [23:0] dev;
		begin
			I2C_TX_BYTE(dev);
			I2C_SLAVE_ACK;
			if (ack==`BIT0)
				begin
					I2C_TX_BYTE(dev[15:8]);
					I2C_SLAVE_ACK;
					if (ack==`BIT0)
						begin
						 	I2C_TX_BYTE(dev[23:16]);
						 	I2C_SLAVE_ACK;
						end
					end
			if (ack==`BIT0)
				$display ("write,=%h ack",dev);
			else
				$display ("write,=%h not ack",dev);
		end
	endtask

	task I2C_READ_BYTE;
		output [7:0] dev;
		begin
			I2C_RX_BYTE(dev);
			I2C_MASTER_ACK(1);
			$display ("Master get data = %h",dev);
			$display ("Master not ack");
		end
	endtask
	
	task I2C_write_in;//
		input [7:0]device;
		input [7:0]subaddr;
		input [7:0]data; 
		begin
			I2C_START;
			I2C_WRITE_DEVICE(device[7:0]);
			I2C_WRITE_SUBADDR(subaddr);
			I2C_WRITE_BYTE(data);
			I2C_STOP;
		end	
	endtask

	task I2C_read_in;
		input [7:0]device;
		input [7:0]subaddr;
		input [7:0]data;
		begin
			I2C_START;
			I2C_WRITE_DEVICE(device[7:0]);
			I2C_WRITE_SUBADDR(subaddr);
			I2C_START;
			I2C_WRITE_DEVICE(device[7:0]);
			I2C_READ_BYTE(test);
			if(test == data)  $display ("....i2c read ok!!.....");
			else               $display ("....i2c read fail!!.....");
			I2C_STOP;
		end	
	endtask

	task I2C_write_read;
		input [7:0]device;
		input [7:0]subaddr;
		input [7:0]data; 
		begin
			I2C_write_in(device,subaddr,data);
			I2C_read_in(device,subaddr,data);
		end	
	endtask
