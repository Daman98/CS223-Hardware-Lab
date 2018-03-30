----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2018 12:59:46 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
generic (
    g_CLKS_PER_BIT : integer := 10416    -- Needs to be set correctly
);
port(
     clk : in std_logic;
     i_RX_Serial : in  std_logic;
     sel : in std_logic_vector(3 downto 0);
     i_TX_DV     : in  std_logic;
     o_TX_Serial : out std_logic;
     ou : out std_logic_vector(15 downto 0)
     );
end top;

architecture rtl of top is
    type ram_type is array (15 downto 0) of std_logic_vector(15 downto 0);
    signal ram : ram_type;
    
    type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits, s_RX_Stop_Bit,s_calc, s_Cleanup);
    signal r_SM_Main : t_SM_Main := s_Idle;
    type trans_main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,s_TX_Stop_Bit, s_Cleanup);
    signal trans_state : trans_main := s_Idle;
     
    signal r_RX_Data_R : std_logic := '0';
    signal r_RX_Data   : std_logic := '0';
       
    signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
    signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
    signal s_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
    signal s_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
    signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
    signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
    signal r_TX_Done   : std_logic := '0';
    
begin
        p_SAMPLE : process (clk)
          begin
            if rising_edge(clk) then
              r_RX_Data_R <= i_RX_Serial;
              r_RX_Data   <= r_RX_Data_R;
            end if;
          end process p_SAMPLE;
        
        --Recieving Part 
        p_UART_RX : process (clk)
        variable mode : std_logic_vector(3 downto 0);
        variable addr : std_logic_vector(3 downto 0);        
        variable dis_addr : std_logic_vector(3 downto 0);
        variable inp : std_logic := '0';
        variable ram_copy : ram_type;
        variable temp : std_logic_vector(15 downto 0);
        variable midsum : std_logic_vector(15 downto 0);
        variable ran : std_logic_vector(15 downto 0);
        variable c : integer range 0 to 10 := 0;
        variable ma : integer range 0 to 10 := 0;
        begin
          if rising_edge(clk) then
               
            case r_SM_Main is
       
              when s_Idle =>
                r_Clk_Count <= 0;
                r_Bit_Index <= 0;
       
                if r_RX_Data = '0' then       -- Start bit detected
                  r_SM_Main <= s_RX_Start_Bit;
                else
                  r_SM_Main <= s_Idle;
                end if;
       
                 
              -- Check middle of start bit to make sure it's still low
              when s_RX_Start_Bit =>
                if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
                  if r_RX_Data = '0' then
                    r_Clk_Count <= 0;  -- reset counter since we found the middle
                    r_SM_Main   <= s_RX_Data_Bits;
                  else
                    r_SM_Main   <= s_Idle;
                  end if;
                else
                  r_Clk_Count <= r_Clk_Count + 1;
                  r_SM_Main   <= s_RX_Start_Bit;
                end if;
       
                 
              -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
              when s_RX_Data_Bits =>
                if r_Clk_Count < g_CLKS_PER_BIT-1 then
                  r_Clk_Count <= r_Clk_Count + 1;
                  r_SM_Main   <= s_RX_Data_Bits;
                else
                  r_Clk_Count            <= 0;
                  r_RX_Byte(r_Bit_Index) <= r_RX_Data;
                   
                  -- Check if we have sent out all bits
                  if r_Bit_Index < 7 then
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_Data_Bits;
                  else
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_Stop_Bit;
                  end if;
                end if;
       
       
              -- Receive Stop bit.  Stop bit = 1
              when s_RX_Stop_Bit =>
                -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if r_Clk_Count < g_CLKS_PER_BIT-1 then
                  r_Clk_Count <= r_Clk_Count + 1;
                  r_SM_Main   <= s_RX_Stop_Bit;
                else
                  r_Clk_Count <= 0;
                  r_SM_Main   <= s_calc;
                end if;
       
              when s_calc =>
                mode := r_RX_Byte(7 downto 4);
                --Input Mode is 0000 inp defines whether it is currently in INPUT Mode or Not
                if mode = "0000" and inp = '0'then 
                    inp := '1';
                    addr := r_RX_Byte(3 downto 0);
                    r_SM_Main <= s_Idle;
                --If Already in Input Mode
                elsif inp = '1' then
                    ram_copy(conv_integer(addr)):= r_RX_Byte;
                    inp := '0';
                    ram <= ram_copy;
                    r_SM_Main <= s_Cleanup;
                --Calculation Mode
                elsif mode = "0011" then
                    -- Calculating Sum of Numbers
                    ram_copy(8):= ram_copy(0)+ ram_copy(1)+ ram_copy(2)+ ram_copy(3)+ ram_copy(4)+ ram_copy(5)+ ram_copy(6)+ram_copy(7);
                    
                    -- Calculating Mean of Numbers
                    ram_copy(9) := "000" & ram_copy(8)(15 downto 3);
                    
                    -- Sorting Numbers (Bubble Sort)
                    for i in 0 to 6 loop
                        for j in 0 to 6-i loop
                            if ram_copy(j) > ram_copy(j+1) then
                                temp := ram_copy(j);
                                ram_copy(j) := ram_copy(j+1);
                                ram_copy(j+1) := temp ;
                            end if;
                        end loop;
                    end loop;
                    
                    --Finding Median of Numbers After Sorting
                    midsum := ram_copy(3)+ram_copy(4);
                    ram_copy(10) := '0' & midsum(15 downto 1);
                    
                    --Maximum of Numbers
                    ram_copy(11) := ram_copy(7);
                    
                    --Minimum of Numbers
                    ram_copy(12) := ram_copy(0);
                    
                    --Finding Mode of Given Numbers
                    for i in 0 to 6 loop
                        if ram_copy(i) = ram_copy (i+1) then
                            c := c+1;
                            if c > ma then
                               ma := c;
                               ram_copy(13) := ram_copy(i); 
                            end if;
                        end if;
                    end loop;
                    
                    --Finding Range
                    ram_copy(14) := ram_copy(7) - ram_copy(0);
                    
                    --Finding Mid-Range
                    ran := ram_copy(7)+ram_copy(0);
                    ram_copy(15) := '0' & ran(15 downto 1);
                    r_SM_Main <= s_Cleanup;
                    ram <= ram_copy;
                --Display Mode
                elsif mode="0001" then
                    dis_addr := r_RX_Byte(3 downto 0);
                    ou <= ram(conv_integer(dis_addr));
                    r_SM_Main <= s_Cleanup;
                --RESET Mode
                elsif mode="0010" then    
                    for i in 0 to 15 loop
                        ram_copy(i) := "0000000000000000";
                    end loop;
                    ram <= ram_copy;
                    r_SM_Main <= s_Cleanup;
                end if;
                --sele <= sel;         
              -- Stay here 1 clock
              when s_Cleanup =>
                inp := '0';
                r_SM_Main <= s_Idle;
       
                   
              when others =>
                r_SM_Main <= s_Idle;
       
            end case;
          end if;
        end process p_UART_RX;
        
        --Transmission Part
        p_UART_TX : process (clk)
          begin
            if rising_edge(clk) then
                 
              case trans_state is
         
                when s_Idle =>
                  o_TX_Serial <= '1';         -- Drive Line High for Idle
                  r_TX_Done   <= '0';
                  s_Clk_Count <= 0;
                  s_Bit_Index <= 0;
         
                  if i_TX_DV = '1' then
                    r_TX_Data <= ram(conv_integer(sel))(7 downto 0); --Here we are assigning value which need to be displayed
                    trans_state <= s_TX_Start_Bit;
                  else
                    trans_state <= s_Idle;
                  end if;
         
                   
                -- Send out Start Bit. Start bit = 0
                when s_TX_Start_Bit =>
                  o_TX_Serial <= '0';
         
                  -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
                  if s_Clk_Count < g_CLKS_PER_BIT-1 then
                    s_Clk_Count <= s_Clk_Count + 1;
                    trans_state   <= s_TX_Start_Bit;
                  else
                    s_Clk_Count <= 0;
                    trans_state   <= s_TX_Data_Bits;
                  end if;
         
                   
                -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish          
                when s_TX_Data_Bits =>
                  o_TX_Serial <= r_TX_Data(s_Bit_Index);
                   
                  if s_Clk_Count < g_CLKS_PER_BIT-1 then
                    s_Clk_Count <= s_Clk_Count + 1;
                    trans_state   <= s_TX_Data_Bits;
                  else
                    s_Clk_Count <= 0;
                     
                    -- Check if we have sent out all bits
                    if s_Bit_Index < 7 then
                      s_Bit_Index <= s_Bit_Index + 1;
                      trans_state   <= s_TX_Data_Bits;
                    else
                      s_Bit_Index <= 0;
                      trans_state   <= s_TX_Stop_Bit;
                    end if;
                  end if;
         
         
                -- Send out Stop bit.  Stop bit = 1
                when s_TX_Stop_Bit =>
                  o_TX_Serial <= '1';
         
                  -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                  if s_Clk_Count < g_CLKS_PER_BIT-1 then
                    s_Clk_Count <= s_Clk_Count + 1;
                    trans_state   <= s_TX_Stop_Bit;
                  else
                    r_TX_Done   <= '1';
                    s_Clk_Count <= 0;
                    trans_state   <= s_Cleanup;
                  end if;
         
                           
                -- Stay here 1 clock
                when s_Cleanup =>
                  r_TX_Done   <= '1';
                  trans_state   <= s_Idle;
                   
                     
                when others =>
                  trans_state <= s_Idle;
         
              end case;
            end if;
          end process p_UART_TX;
end rtl;
