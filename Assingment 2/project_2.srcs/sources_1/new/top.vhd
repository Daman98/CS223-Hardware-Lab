

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
entity top is
	port (
	    enable : in std_logic;
		clka : in std_logic;
		button : in std_logic;
		address : in std_logic_vector(15 downto 0);
		out_led : out std_logic_vector(7 downto 0)
	    );
end top;
architecture Behavioral of top is
  component design_1 is
port (
  clka : in STD_LOGIC;
  dina : in STD_LOGIC_VECTOR ( 9 downto 0 );
  do2 : out STD_LOGIC_VECTOR ( 9 downto 0 );
  do3 : out STD_LOGIC_VECTOR ( 9 downto 0 );
  do4 : out STD_LOGIC_VECTOR ( 9 downto 0 );
  do1 : out STD_LOGIC_VECTOR ( 9 downto 0 );
  we2 : in STD_LOGIC_VECTOR ( 0 to 0 );
  we3 : in STD_LOGIC_VECTOR ( 0 to 0 );
  we4 : in STD_LOGIC_VECTOR ( 0 to 0 );
  we1 : in STD_LOGIC_VECTOR ( 0 to 0 );
  addra : in STD_LOGIC_VECTOR ( 4 downto 0 )
);
end component design_1;
	signal tag : std_logic_vector(6 downto 0);
--	-- 18 ... 0
--	-- 2 lru 1 valid baki data
	signal set : std_logic_vector(4 downto 0);
	signal addra : std_logic_vector(4 downto 0) := "00000";
	signal dina : std_logic_vector(9 downto 0) := "0000000000";
	signal do1 : std_logic_vector(9 downto 0) := "0000000000";
    signal do2 : std_logic_vector(9 downto 0) := "0000000000";
	signal do3 : std_logic_vector(9 downto 0) := "0000000000";
	signal do4 : std_logic_vector(9 downto 0) := "0000000000";
	signal we1 : std_logic_vector(0 downto 0) := "0";
    signal we2 : std_logic_vector(0 downto 0) := "0";
	signal we3 : std_logic_vector(0 downto 0) := "0";
	signal we4 : std_logic_vector(0 downto 0) := "0";
    signal clock : std_logic_vector(16 downto 0);
    type main_SM is (idle,complete, tag_comp, replaced_2_dash,replaced_dash, missed,we1_disable,replaced,replaced_2,end_lru);
    signal SM : main_SM := idle;
    signal miss : std_logic_vector(3 downto 0) := "0000";
    signal hit : std_logic_vector(3 downto 0) := "0000";
--	signal disabled : std_logic := '1';
--    signal en: std_logic := '0';
--    signal misser: std_logic_vector(5 downto 0):= "000000";
    signal lru_counter: integer;
    signal lru_state: std_logic_vector(1 downto 0);
    signal lru_found: integer;
    signal lru_point:integer;
begin

--process(clka)
--begin
--if(rising_edge(clka)) then
--clock <= clock + '1';
--end if;
--end process;

process(clka)
variable set_start : std_logic_vector(6 downto 0);
variable temp : integer;
--variable lru_state : std_logic_vector(1 downto 0);
variable temp2: std_logic_vector(9 downto 0);
variable i: integer;
begin
if (rising_edge(clka)) then
    tag <= address(15 downto 9);
    set <= address(8 downto 4);
    case SM is
        when idle =>
            addra <= set;
            if button = '1' then
                SM <= tag_comp;
            else
                SM <= idle;
            end if;
            
        when tag_comp =>
            if tag = do1(6 downto 0) and do1(7)='1' then
                hit <= hit+'1';
                lru_found <= 0;
                lru_counter <= 0;
                lru_state <= do1(9 downto 8);
                SM <= replaced;
            elsif tag = do2(6 downto 0)  and do2(7)='1'  then
                hit <= hit+'1';
                lru_found <= 1;
                lru_counter <= 0;
                lru_state <= do2(9 downto 8);
                SM <= replaced;
            elsif tag = do3(6 downto 0)  and do3(7)='1' then
                hit <= hit+'1';
                lru_found <= 2;
                lru_counter <= 0;
                lru_state <= do3(9 downto 8);
                SM <= replaced;
            elsif tag = do4(6 downto 0)  and do4(7)='1'  then
                hit <= hit+1;
                lru_found <= 3;
                lru_counter <= 0;
                lru_state <= do4(9 downto 8);
                SM <= replaced;
            else
                miss <= miss+'1';
                lru_counter <= 0;
                lru_state<="00";
                SM <= replaced_dash;
            end if;
        
        when replaced =>
            if lru_counter = 0 then
                if(do1(9 downto 8)>lru_state and do1(7)='1') then
                    dina <= (do1(9 downto 8) - '1') & do1(7 downto 0);
                                    we1(0) <= '1';

                elsif(do1(9 downto 8) = lru_state and do1(7)='1') then
                    lru_point <= 0;
                end if;
                SM <= replaced_2;
            elsif lru_counter = 1 then
                
                if(do2(9 downto 8)>lru_state and do2(7)='1') then
                    dina <= (do2(9 downto 8) - '1') & do2(7 downto 0);
                                    we2(0) <= '1';

                elsif(do2(9 downto 8) = lru_state and do2(7)='1') then
                    lru_point <= 1;
                end if;
                SM <= replaced_2;
            elsif lru_counter = 2 then
               
                if(do3(9 downto 8)>lru_state and do3(7)='1') then
                    dina <= (do3(9 downto 8) - '1') & do3(7 downto 0);
                                we3(0) <= '1';

                elsif(do3(9 downto 8) = lru_state and do3(7)='1') then
                    lru_point <= 2;                
                end if;
                SM <= replaced_2;
            elsif lru_counter = 3 then
                
                if(do4(9 downto 8)>lru_state and do4(7)='1') then
                    dina <= (do4(9 downto 8) - '1') & do4(7 downto 0);
                                we4(0) <= '1';

                elsif(do4(9 downto 8) = lru_state and do4(7)='1') then
                    lru_point <= 3;                
                end if;
                SM <= replaced_2;
            elsif lru_counter > 3 then
                SM <= end_lru;
            end if;
            
       when replaced_2 =>
        we1(0) <= '0'; 
        we2(0) <= '0'; 
        we3(0) <= '0'; 
        we4(0) <= '0'; 
        lru_counter <= lru_counter + 1; 
       SM <= replaced;

        when replaced_dash =>
            if lru_counter = 0 then
--                if(dol(7) = '1') then
                if(do1(9 downto 8)>lru_state and do1(7)='1') then
                    dina <= (do1(9 downto 8) - '1') & do1(7 downto 0);
                    we1(0) <= '1';
                elsif(do1(9 downto 8) = lru_state or do1(7)='0') then
                    lru_point <= 0;
                end if;
--                end if;
                
                SM <= replaced_2_dash;
            elsif lru_counter = 1 then
                
                if(do2(9 downto 8)>lru_state and do2(7)='1') then
                    dina <= (do2(9 downto 8) - '1') & do2(7 downto 0);
                we2(0) <= '1';
                elsif(do2(9 downto 8) = lru_state or do2(7)='0') then
                    lru_point <= 1;
                end if;
                
                SM <= replaced_2_dash;
            elsif lru_counter = 2 then
               
                if(do3(9 downto 8)>lru_state and do3(7)='1') then
                    dina <= (do3(9 downto 8) - '1') & do3(7 downto 0);
                                    we3(0) <= '1';

                elsif(do3(9 downto 8) = lru_state or do3(7)='0') then
                    lru_point <= 2;                
                end if;
                SM <= replaced_2_dash;
            elsif lru_counter = 3 then
                
                if(do4(9 downto 8)>lru_state and do4(7)='1') then
                    dina <= (do4(9 downto 8) - '1') & do4(7 downto 0);
                                we4(0) <= '1';
                elsif(do4(9 downto 8) = lru_state or do4(7)='0') then
                    lru_point <= 3;                
                end if;
                SM <= replaced_2_dash;
            elsif lru_counter > 3 then
                SM <= missed;
            end if;
       when replaced_2_dash =>
        we1(0) <= '0'; 
        we2(0) <= '0'; 
        we3(0) <= '0'; 
        we4(0) <= '0'; 
        lru_counter <= lru_counter + 1; 
       SM <= replaced_dash;

       when end_lru =>
       lru_counter <= 0;
        if lru_found = 0 then
            temp2:= do1;
            dina <= "11" & temp2(7 downto 0);
            we1(0) <= '1';
        elsif lru_found = 1 then
            temp2:= do2;
            dina <= "11" & temp2(7 downto 0);
            we2(0) <= '1';
       elsif lru_found = 2 then
            temp2:= do3;
            dina <= "11" & temp2(7 downto 0);
            we3(0) <= '1';
        elsif lru_found = 3 then
            temp2:= do4;
            dina <= "11" & temp2(7 downto 0);
            we4(0) <= '1';
        end if;
    SM <= complete;        
        when complete =>
        we1(0) <= '0'; 
        we2(0) <= '0'; 
        we3(0) <= '0'; 
        we4(0) <= '0'; 
        SM <= idle;                        
           
        when missed =>
            if lru_point = 0 then
                dina(9 downto 0) <= "111" & tag;
                we1(0) <= '1';
            elsif lru_point = 1 then
                dina(9 downto 0) <= "111" & tag;
                we2(0) <= '1';
            elsif lru_point = 2 then
                dina(9 downto 0) <= "111" & tag;
                we3(0) <= '1';
            elsif lru_point = 3 then
                dina(9 downto 0) <= "111" & tag;
                we4(0) <= '1';
            end if;
 		SM <= complete;       
        when others =>
            SM <= idle;
                             
    end case;
end if;
end process;
out_led <= hit & miss;

design_1_i: component design_1
     port map (
      addra(4 downto 0) => addra(4 downto 0),
      clka => clka,
      dina(9 downto 0) => dina(9 downto 0),
      do1(9 downto 0) => do1(9 downto 0),
      do2(9 downto 0) => do2(9 downto 0),
      do3(9 downto 0) => do3(9 downto 0),
      do4(9 downto 0) => do4(9 downto 0),
      we1(0) => we1(0),
      we2(0) => we2(0),
      we3(0) => we3(0),
      we4(0) => we4(0)
    );

end Behavioral;