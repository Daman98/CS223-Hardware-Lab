library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity UART_RX is
  generic (
    g_CLKS_PER_BIT : integer := 10416     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    sw : in std_logic_vector (6 downto 0); --to check count of word on the location
    mode     : in std_logic; --to decide saving words or entering query
    Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
    LED_out : out STD_LOGIC_VECTOR (6 downto 0);
    o_RX_Byte   : out std_logic_vector(15 downto 0)
    );
end UART_RX;
 
 
architecture rtl of UART_RX is
  type ram_type is array (127 downto 0) of std_logic_vector(127 downto 0);
    type ram_store is array (127 downto 0) of integer;
signal ram_data : ram_store;
  signal ram : ram_type;
  signal final_count : ram_store;
  type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits, save_state, update_state, char_count_update, word_count_update,
                     s_RX_Stop_Bit, s_Cleanup);
  type state_machine is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,shift_char, add_new_char,compare, check,
                         s_RX_Stop_Bit, s_Cleanup);
  signal r_SM_Main : t_SM_Main := s_Idle;
  signal SM2 : state_machine := s_Idle;
  signal r_RX_Data_R : std_logic := '0';
  signal r_RX_Data   : std_logic := '0';
   
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 127 := 0;  -- 128 Bits Total(16 char)
  signal word_count : integer range 0 to 127 := 0;
  signal char_count : integer range 0 to 17 := 1 ;
  signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal temp : integer := 0 ;
  signal r_RX_DV     : std_logic := '0';
  signal curr_word : std_logic_vector(127 downto 0);
  signal out_ans : std_logic_vector(15 downto 0);
  --signal var : integer:=0;
  signal refresh_counter : std_logic_vector(17 downto 0);
  signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0);
  signal Counter: STD_LOGIC_VECTOR (1 downto 0);
   
  function to_bcd ( bin : std_logic_vector(15 downto 0) ) return std_logic_vector is
  variable i : integer:=0;
  variable bcd : std_logic_vector(19 downto 0) := (others => '0');
  variable bint : std_logic_vector(15 downto 0) := bin;
  
  begin
  for i in 0 to 15 loop  -- repeating 8 times.
  bcd(19 downto 1) := bcd(18 downto 0);  --shifting the bits.
  bcd(0) := bint(15);
  bint(15 downto 1) := bint(14 downto 0);
  bint(0) :='0';
  
  
  if(i < 15 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
  bcd(3 downto 0) := bcd(3 downto 0) + "0011";
  end if;
  
  if(i < 15 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
  bcd(7 downto 4) := bcd(7 downto 4) + "0011";
  end if;
  
  if(i < 15 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
  bcd(11 downto 8) := bcd(11 downto 8) + "0011";
  end if;
  
  if(i < 15 and bcd(15 downto 12) > "0100") then  --add 3 if BCD digit is greater than 4.
  bcd(11 downto 8) := bcd(11 downto 8) + "0011";
  end if;
  
  if(i < 15 and bcd(19 downto 16) > "0100") then  --add 3 if BCD digit is greater than 4.
  bcd(11 downto 8) := bcd(11 downto 8) + "0011";
  end if;
  end loop;
  return bcd;
  end to_bcd;

begin
  -- Purpose: Double-register the incoming data.
  -- This allows it to be used in the UART RX Clock Domain.
  -- (It removes problems caused by metastabiliy)
  p_SAMPLE : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      r_RX_Data_R <= i_RX_Serial;
      r_RX_Data   <= r_RX_Data_R;
    end if;
  end process p_SAMPLE;

  -- Purpose: Control RX state machine
  p_UART_RX : process (i_Clk)
  variable var : integer:=0;
  variable x : integer:=0;
  variable t : std_logic_vector(127 downto 0):="00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  begin
  if rising_edge(i_Clk) then
    if mode = '0' then
         
      case r_SM_Main is
 
        when s_Idle =>
          r_RX_DV     <= '0';
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
                r_SM_Main   <= save_state;
              end if;
            end if;

        when save_state =>
            ram(word_count)(char_count*8-1 downto char_count*8-8) <= r_RX_Byte;
            if(r_RX_Byte /= "00110000") then
                ram_data(word_count) <= ram_data(word_count) + 1;

            end if;
            r_SM_Main   <= char_count_update;            
        
        when char_count_update =>
            char_count <= char_count + 1;
            r_SM_Main   <= word_count_update;            
        
        when word_count_update =>
            if char_count = 17 then
                word_count <= word_count + 1 ;
                char_count <= 1 ;
                ram_data(word_count+1) <= 0;
            end if;
            r_SM_Main   <= s_RX_Stop_Bit; 
        -- Receive Stop bit.  Stop bit = 1
        when s_RX_Stop_Bit =>
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Stop_Bit;
          else
            r_RX_DV     <= '1';
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup;
          end if;
 
                   
        -- Stay here 1 clock
        when s_Cleanup =>
          r_SM_Main <= s_Idle;
          r_RX_DV   <= '0';
 
             
        when others =>
          r_SM_Main <= s_Idle;
 
      end case;
      
    elsif mode = '1' then
    
    case SM2 is
     
        when s_Idle =>
          r_RX_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
 
          if r_RX_Data = '0' then       -- Start bit detected
            SM2 <= s_RX_Start_Bit;
          else
            SM2 <= s_Idle;
          end if;
 
           
        -- Check middle of start bit to make sure it's still low
        when s_RX_Start_Bit =>
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            if r_RX_Data = '0' then
              r_Clk_Count <= 0;  -- reset counter since we found the middle
              SM2   <= s_RX_Data_Bits;
            else
              SM2   <= s_Idle;
            end if;
          else
            r_Clk_Count <= r_Clk_Count + 1;
            SM2   <= s_RX_Start_Bit;
          end if;
 
           
        -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
        when s_RX_Data_Bits =>
            if r_Clk_Count < g_CLKS_PER_BIT-1 then
                r_Clk_Count <= r_Clk_Count + 1;
                SM2   <= s_RX_Data_Bits;
              else
                r_Clk_Count            <= 0;
                r_RX_Byte(r_Bit_Index) <= r_RX_Data;
                 
                -- Check if we have sent out all bits
                if r_Bit_Index < 7 then
                  r_Bit_Index <= r_Bit_Index + 1;
                  SM2   <= s_RX_Data_Bits;
                else
                  r_Bit_Index <= 0;
                  temp <= temp +1;
                  SM2   <= shift_char;
                end if;
              end if;
        
        when shift_char =>
            curr_word(119 downto 0)<= curr_word(127 downto 8);
        SM2 <= add_new_char;
        
        when add_new_char =>
            curr_word(127 downto 120) <= r_RX_Byte;
        if temp >= 16 then
            var := ram_data(1)*8-1;
            SM2 <= compare;
        else
            SM2 <= s_RX_Stop_Bit;
        end if;
        
        when compare =>
        --Parallel checking for word on the current 16 character string
        for i in 1 to 16 loop
        if ram(0)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(0)(i*8-1 downto i*8-8) then
        t(0) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(1)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(1)(i*8-1 downto i*8-8) then
        t(1) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(2)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(2)(i*8-1 downto i*8-8) then
        t(2) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(3)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(3)(i*8-1 downto i*8-8) then
        t(3) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(4)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(4)(i*8-1 downto i*8-8) then
        t(4) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(5)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(5)(i*8-1 downto i*8-8) then
        t(5) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(6)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(6)(i*8-1 downto i*8-8) then
        t(6) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(7)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(7)(i*8-1 downto i*8-8) then
        t(7) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(8)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(8)(i*8-1 downto i*8-8) then
        t(8) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(9)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(9)(i*8-1 downto i*8-8) then
        t(9) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(10)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(10)(i*8-1 downto i*8-8) then
        t(10) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(11)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(11)(i*8-1 downto i*8-8) then
        t(11) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(12)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(12)(i*8-1 downto i*8-8) then
        t(12) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(13)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(13)(i*8-1 downto i*8-8) then
        t(13) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(14)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(14)(i*8-1 downto i*8-8) then
        t(14) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(15)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(15)(i*8-1 downto i*8-8) then
        t(15) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(16)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(16)(i*8-1 downto i*8-8) then
        t(16) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(17)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(17)(i*8-1 downto i*8-8) then
        t(17) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(18)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(18)(i*8-1 downto i*8-8) then
        t(18) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(19)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(19)(i*8-1 downto i*8-8) then
        t(19) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(20)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(20)(i*8-1 downto i*8-8) then
        t(20) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(21)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(21)(i*8-1 downto i*8-8) then
        t(21) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(22)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(22)(i*8-1 downto i*8-8) then
        t(22) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(23)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(23)(i*8-1 downto i*8-8) then
        t(23) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(24)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(24)(i*8-1 downto i*8-8) then
        t(24) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(25)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(25)(i*8-1 downto i*8-8) then
        t(25) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(26)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(26)(i*8-1 downto i*8-8) then
        t(26) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(27)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(27)(i*8-1 downto i*8-8) then
        t(27) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(28)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(28)(i*8-1 downto i*8-8) then
        t(28) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(29)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(29)(i*8-1 downto i*8-8) then
        t(29) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(30)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(30)(i*8-1 downto i*8-8) then
        t(30) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(31)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(31)(i*8-1 downto i*8-8) then
        t(31) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(32)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(32)(i*8-1 downto i*8-8) then
        t(32) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(33)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(33)(i*8-1 downto i*8-8) then
        t(33) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(34)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(34)(i*8-1 downto i*8-8) then
        t(34) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(35)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(35)(i*8-1 downto i*8-8) then
        t(35) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(36)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(36)(i*8-1 downto i*8-8) then
        t(36) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(37)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(37)(i*8-1 downto i*8-8) then
        t(37) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(38)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(38)(i*8-1 downto i*8-8) then
        t(38) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(39)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(39)(i*8-1 downto i*8-8) then
        t(39) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(40)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(40)(i*8-1 downto i*8-8) then
        t(40) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(41)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(41)(i*8-1 downto i*8-8) then
        t(41) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(42)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(42)(i*8-1 downto i*8-8) then
        t(42) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(43)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(43)(i*8-1 downto i*8-8) then
        t(43) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(44)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(44)(i*8-1 downto i*8-8) then
        t(44) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(45)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(45)(i*8-1 downto i*8-8) then
        t(45) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(46)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(46)(i*8-1 downto i*8-8) then
        t(46) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(47)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(47)(i*8-1 downto i*8-8) then
        t(47) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(48)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(48)(i*8-1 downto i*8-8) then
        t(48) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(49)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(49)(i*8-1 downto i*8-8) then
        t(49) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(50)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(50)(i*8-1 downto i*8-8) then
        t(50) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(51)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(51)(i*8-1 downto i*8-8) then
        t(51) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(52)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(52)(i*8-1 downto i*8-8) then
        t(52) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(53)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(53)(i*8-1 downto i*8-8) then
        t(53) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(54)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(54)(i*8-1 downto i*8-8) then
        t(54) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(55)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(55)(i*8-1 downto i*8-8) then
        t(55) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(56)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(56)(i*8-1 downto i*8-8) then
        t(56) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(57)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(57)(i*8-1 downto i*8-8) then
        t(57) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(58)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(58)(i*8-1 downto i*8-8) then
        t(58) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(59)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(59)(i*8-1 downto i*8-8) then
        t(59) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(60)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(60)(i*8-1 downto i*8-8) then
        t(60) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(61)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(61)(i*8-1 downto i*8-8) then
        t(61) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(62)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(62)(i*8-1 downto i*8-8) then
        t(62) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(63)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(63)(i*8-1 downto i*8-8) then
        t(63) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(64)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(64)(i*8-1 downto i*8-8) then
        t(64) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(65)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(65)(i*8-1 downto i*8-8) then
        t(65) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(66)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(66)(i*8-1 downto i*8-8) then
        t(66) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(67)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(67)(i*8-1 downto i*8-8) then
        t(67) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(68)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(68)(i*8-1 downto i*8-8) then
        t(68) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(69)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(69)(i*8-1 downto i*8-8) then
        t(69) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(70)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(70)(i*8-1 downto i*8-8) then
        t(70) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(71)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(71)(i*8-1 downto i*8-8) then
        t(71) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(72)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(72)(i*8-1 downto i*8-8) then
        t(72) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(73)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(73)(i*8-1 downto i*8-8) then
        t(73) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(74)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(74)(i*8-1 downto i*8-8) then
        t(74) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(75)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(75)(i*8-1 downto i*8-8) then
        t(75) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(76)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(76)(i*8-1 downto i*8-8) then
        t(76) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(77)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(77)(i*8-1 downto i*8-8) then
        t(77) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(78)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(78)(i*8-1 downto i*8-8) then
        t(78) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(79)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(79)(i*8-1 downto i*8-8) then
        t(79) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(80)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(80)(i*8-1 downto i*8-8) then
        t(80) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(81)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(81)(i*8-1 downto i*8-8) then
        t(81) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(82)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(82)(i*8-1 downto i*8-8) then
        t(82) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(83)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(83)(i*8-1 downto i*8-8) then
        t(83) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(84)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(84)(i*8-1 downto i*8-8) then
        t(84) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(85)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(85)(i*8-1 downto i*8-8) then
        t(85) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(86)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(86)(i*8-1 downto i*8-8) then
        t(86) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(87)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(87)(i*8-1 downto i*8-8) then
        t(87) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(88)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(88)(i*8-1 downto i*8-8) then
        t(88) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(89)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(89)(i*8-1 downto i*8-8) then
        t(89) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(90)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(90)(i*8-1 downto i*8-8) then
        t(90) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(91)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(91)(i*8-1 downto i*8-8) then
        t(91) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(92)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(92)(i*8-1 downto i*8-8) then
        t(92) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(93)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(93)(i*8-1 downto i*8-8) then
        t(93) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(94)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(94)(i*8-1 downto i*8-8) then
        t(94) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(95)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(95)(i*8-1 downto i*8-8) then
        t(95) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(96)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(96)(i*8-1 downto i*8-8) then
        t(96) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(97)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(97)(i*8-1 downto i*8-8) then
        t(97) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(98)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(98)(i*8-1 downto i*8-8) then
        t(98) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(99)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(99)(i*8-1 downto i*8-8) then
        t(99) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(100)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(100)(i*8-1 downto i*8-8) then
        t(100) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(101)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(101)(i*8-1 downto i*8-8) then
        t(101) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(102)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(102)(i*8-1 downto i*8-8) then
        t(102) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(103)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(103)(i*8-1 downto i*8-8) then
        t(103) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(104)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(104)(i*8-1 downto i*8-8) then
        t(104) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(105)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(105)(i*8-1 downto i*8-8) then
        t(105) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(106)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(106)(i*8-1 downto i*8-8) then
        t(106) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(107)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(107)(i*8-1 downto i*8-8) then
        t(107) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(108)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(108)(i*8-1 downto i*8-8) then
        t(108) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(109)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(109)(i*8-1 downto i*8-8) then
        t(109) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(110)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(110)(i*8-1 downto i*8-8) then
        t(110) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(111)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(111)(i*8-1 downto i*8-8) then
        t(111) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(112)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(112)(i*8-1 downto i*8-8) then
        t(112) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(113)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(113)(i*8-1 downto i*8-8) then
        t(113) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(114)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(114)(i*8-1 downto i*8-8) then
        t(114) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(115)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(115)(i*8-1 downto i*8-8) then
        t(115) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(116)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(116)(i*8-1 downto i*8-8) then
        t(116) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(117)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(117)(i*8-1 downto i*8-8) then
        t(117) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(118)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(118)(i*8-1 downto i*8-8) then
        t(118) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(119)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(119)(i*8-1 downto i*8-8) then
        t(119) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(120)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(120)(i*8-1 downto i*8-8) then
        t(120) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(121)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(121)(i*8-1 downto i*8-8) then
        t(121) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(122)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(122)(i*8-1 downto i*8-8) then
        t(122) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(123)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(123)(i*8-1 downto i*8-8) then
        t(123) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(124)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(124)(i*8-1 downto i*8-8) then
        t(124) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(125)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(125)(i*8-1 downto i*8-8) then
        t(125) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(126)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(126)(i*8-1 downto i*8-8) then
        t(126) := '1';
        end if;
        end if;
        end loop;
        for i in 1 to 16 loop
        if ram(127)(i*8-1 downto i*8-8) /= "00110000" then
        if curr_word(i*8-1 downto i*8-8) /= ram(127)(i*8-1 downto i*8-8) then
        t(127) := '1';
        end if;
        end if;
        end loop;

            SM2 <= check;
        
        when check=>
        --checking which ones to add
            for  i in 0 to 127 loop
                if t(i) = '0' then
                    final_count(i) <= final_count(i)+1;
                else
                    t(i) := '0';             
                end if;
            end loop;

        SM2 <= s_RX_Stop_Bit;        
         -- Receive Stop bit.  Stop bit = 1
        when s_RX_Stop_Bit =>
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            SM2   <= s_RX_Stop_Bit;
          else
            r_RX_DV     <= '1';
            r_Clk_Count <= 0;
            SM2   <= s_Cleanup;
          end if;
 
                   
        -- Stay here 1 clock
        when s_Cleanup =>
          SM2 <= s_Idle;
          r_RX_DV   <= '0';
 
             
        when others =>
          SM2 <= s_Idle;
 
      end case;
    end if;
    end if;
  end process p_UART_RX;
  
  process(i_Clk)
  begin 
      if(rising_edge(i_Clk)) then
          refresh_counter <= refresh_counter + 1;
      end if;
  end process;
  Counter <= refresh_counter(17 downto 16);
  process(Counter)
  begin
      case Counter  is
      when "00" =>
          Anode_Activate <= "0111"; 
          -- activate LED1 and Deactivate LED2, LED3, LED4
          LED_BCD <= out_ans(15 downto 12);
          -- the first hex digit of the 16-bit number
      when "01" =>
          Anode_Activate <= "1011"; 
          -- activate LED2 and Deactivate LED1, LED3, LED4
          LED_BCD <= out_ans(11 downto 8);
          -- the second hex digit of the 16-bit number
      when "10" =>
          Anode_Activate <= "1101"; 
          -- activate LED3 and Deactivate LED2, LED1, LED4
          LED_BCD <= out_ans(7 downto 4);
          -- the third hex digit of the 16-bit number
      when "11" =>
          Anode_Activate <= "1110"; 
          -- activate LED4 and Deactivate LED2, LED3, LED1
          LED_BCD <= out_ans(3 downto 0);
          -- the fourth hex digit of the 16-bit number    
      end case;
  end process;
 process(LED_BCD)
 --process to display led from bcd to their individual elements
  begin
      case LED_BCD is
      when "0000" => LED_out <= "0000001"; -- "0"     
      when "0001" => LED_out <= "1001111"; -- "1" 
      when "0010" => LED_out <= "0010010"; -- "2" 
      when "0011" => LED_out <= "0000110"; -- "3" 
      when "0100" => LED_out <= "1001100"; -- "4" 
      when "0101" => LED_out <= "0100100"; -- "5" 
      when "0110" => LED_out <= "0100000"; -- "6" 
      when "0111" => LED_out <= "0001111"; -- "7" 
      when "1000" => LED_out <= "0000000"; -- "8"     
      when "1001" => LED_out <= "0000100"; -- "9" 
      when "1010" => LED_out <= "0000010"; -- a
      when "1011" => LED_out <= "1100000"; -- b
      when "1100" => LED_out <= "0110001"; -- C
      when "1101" => LED_out <= "1000010"; -- d
      when "1110" => LED_out <= "0110000"; -- E
      when "1111" => LED_out <= "0111000"; -- F
      end case;
  end process;

  o_RX_Byte <= out_ans;
  out_ans <= to_bcd(conv_std_logic_vector(final_count(conv_integer(sw)),16))(15 downto 0);

   
end rtl;