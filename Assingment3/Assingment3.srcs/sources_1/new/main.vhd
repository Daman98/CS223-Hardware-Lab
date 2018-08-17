LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY main IS
	PORT (
		clock : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		S : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		M : IN STD_LOGIC;
		Cn : IN STD_LOGIC;
		G : OUT STD_LOGIC;
		P : OUT STD_LOGIC;
		Cout : OUT STD_LOGIC;
		eanb : OUT STD_LOGIC;
		LED_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		sign: OUT STD_LOGIC;
		Fout : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END main;
ARCHITECTURE Behavioral OF main IS
	SIGNAL n : std_logic_vector(7 DOWNTO 0) := "00000000";
	SIGNAL F : std_logic_vector(3 DOWNTO 0) := "0000";
	SIGNAL G1 : std_logic := '0';
	SIGNAL P1 : std_logic := '0';
	SIGNAL clock_divide : std_logic_vector(20 DOWNTO 0);
	SIGNAL act_LED : std_logic_vector (1 DOWNTO 0);
	SIGNAL LED_bcd : std_logic_vector(3 DOWNTO 0) := "0000";
		SIGNAL psign : std_logic:='0';
	SIGNAL COUTTEMP : std_logic:='0';
	

BEGIN
	n(0) <= NOT(A(0) OR (B(0) AND S(0)) OR (NOT B(0) AND S(1)));
	n(1) <= NOT(A(1) OR (B(1) AND S(0)) OR (NOT B(1) AND S(1)));
	n(2) <= NOT(A(2) OR (B(2) AND S(0)) OR (NOT B(2) AND S(1)));
	n(3) <= NOT(A(3) OR (B(3) AND S(0)) OR (NOT B(3) AND S(1)));
	n(4) <= NOT((NOT B(0) AND S(2) AND A(0)) OR (A(0) AND S(3) AND B(0)));
	n(5) <= NOT((NOT B(1) AND S(2) AND A(1)) OR (A(1) AND S(3) AND B(1)));
	n(6) <= NOT((NOT B(2) AND S(2) AND A(2)) OR (A(2) AND S(3) AND B(2)));
	n(7) <= NOT((NOT B(3) AND S(2) AND A(3)) OR (A(3) AND S(3) AND B(3)));
	F(0) <= (n(0) XOR n(4)) XOR (Cn OR M);
	F(1) <= ((n(0) AND NOT M) NOR (NOT M AND NOT Cn AND n(4))) XOR (n(1) XOR n(5));
	F(2) <= NOT (((n(1) AND NOT M) OR (NOT M AND n(0) AND n(5))) OR (NOT M AND NOT Cn AND n(4) AND n(5))) XOR (n(2) XOR n(6));
	F(3) <= NOT ((NOT M AND n(2)) OR (NOT M AND n(1) AND n(6)) OR (NOT M AND n(0) AND n(5) AND n(6)) OR (NOT M AND NOT Cn AND n(4) AND n(6))) XOR (n(3) XOR n(7));
	psign <= NOT M and S(1) and NOT COUTTEMP and ((S(0)and Cn )or ( not S(3) and S(2) and not S(0) ));

	eanb <= (A(0) XNOR B(0)) AND (A(1) XNOR B(1)) AND (A(2) XNOR B(2)) AND (A(3) XNOR B(3));
	G1 <= NOT (n(4) AND n(5) AND n(6) AND n(7));
	P1 <= NOT (n(3) OR (n(7) AND n(2)) OR (n(7) AND n(6) AND n(1)) OR (n(7) AND n(6) AND n(5) AND n(0)));
	COUTTEMP <= NOT(P1) OR (G1 AND Cn);
	Cout <= COUTTEMP;
	G <= G1;
	P <= P1;
    sign <= psign;
	PROCESS (LED_bcd) BEGIN
        CASE LED_bcd IS
            WHEN "0000" => LED_out <= "0000001";
            WHEN "0001" => LED_out <= "1001111";
            WHEN "0010" => LED_out <= "0010010";
            WHEN "0011" => LED_out <= "0000110";
            WHEN "0100" => LED_out <= "1001100";
            WHEN "0101" => LED_out <= "0100100";
            WHEN "0110" => LED_out <= "0100000";
            WHEN "0111" => LED_out <= "0001111";
            WHEN "1000" => LED_out <= "0000000";
            WHEN "1001" => LED_out <= "0000100";
            WHEN "1010" => LED_out <= "0000010";
            WHEN "1011" => LED_out <= "1100000";
            WHEN "1100" => LED_out <= "0110001";
            WHEN "1101" => LED_out <= "1000010";
            WHEN "1110" => LED_out <= "0110000";
            WHEN "1111" => LED_out <= "0111000";
            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;
    PROCESS (clock)
        BEGIN
            IF (rising_edge(clock)) THEN
                clock_divide <= clock_divide + 1;
            END IF;
	END PROCESS;
	
	act_LED <= clock_divide(20 DOWNTO 19);
	
	PROCESS (act_LED, F)
		BEGIN
			CASE act_LED IS
				WHEN "00" =>
					anode <= "1110";
                    if(psign = '0') then
                        LED_bcd <= F ;
                    else LED_bcd <= not F + '1' ;
                    end if;
					
				WHEN "01" =>
					anode <= "0111";
					LED_bcd <= A;
				WHEN "10" =>
					anode <= "1011";
					LED_bcd <= B;
				WHEN "11" =>
					anode <= "1101";
					LED_bcd <= S;
			END CASE;
		END PROCESS;
END Behavioral;