
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe1_tb IS
   -- empty
END aufgabe1_tb;

ARCHITECTURE verhalten OF aufgabe1_tb IS
   CONSTANT RSTDEF: std_ulogic := '0';
   CONSTANT FRQDEF: real := 50.0e6;
   CONSTANT tpd:    time := 1 sec / FRQDEF;

   COMPONENT aufgabe1 IS
      PORT(rst:  IN  std_logic;                     -- system reset (active low)
           clk:  IN  std_logic;                     -- 50 MHz crystal oscillator, clock source
           btn:  IN  std_logic_vector(4 DOWNTO 1);  -- user push buttons: BTN4 BTN3 BTN2 BTN1 (active low)
           sw:   IN  std_logic_vector(8 DOWNTO 1);  -- 8 slide switches: SW8 SW7 SW6 SW5 SW4 SW3 SW2 SW1 (active low)
           digi: OUT std_logic_vector(4 DOWNTO 1);  -- 4 digit enable (common cathode) signals (active high)
           seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 connections to seven-segment display (active high)
           dp:   OUT std_logic);                    -- 1 connection to digit point (active high)
   END COMPONENT;

   SIGNAL hlt:  std_logic := '0';
   SIGNAL rst:  std_logic := RSTDEF;
   SIGNAL clk:  std_logic := '0';

   SIGNAL sw:   std_logic_vector(8 DOWNTO 1) := (OTHERS => '1');
   SIGNAL btn:  std_logic_vector(4 DOWNTO 1) := (OTHERS => '1');
   SIGNAL digi: std_logic_vector(4 DOWNTO 1) := (OTHERS => '0');
   SIGNAL seg:  std_logic_vector(7 DOWNTO 1) := (OTHERS => '0');
   SIGNAL dp:   std_logic := '0';

BEGIN

   rst <= RSTDEF, NOT RSTDEF AFTER 5*tpd;
   clk <= NOT clk AFTER tpd/2 WHEN hlt='0' ELSE '0';

   u1: aufgabe1
   PORT MAP(rst  => rst,
            clk  => clk,
            btn  => btn,
            sw   => sw,
            digi => digi,
            seg  => seg,
            dp   => dp);

   main: PROCESS

      PROCEDURE test1 IS
      BEGIN
         REPORT "test1..." SEVERITY note;
         IF rst=RSTDEF  THEN
            ASSERT digi/="0000" REPORT "wrong segment" SEVERITY error;
         END IF;
         WAIT UNTIL clk'EVENT AND clk='1' AND rst=(NOT RSTDEF);
         WAIT UNTIL clk'EVENT AND clk='1' AND digi(1)='1';
         WHILE digi(1)='1' LOOP
            ASSERT digi="0001" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
         WAIT UNTIL clk'EVENT AND clk='1' AND digi(2)='1';
         WHILE digi(2)='1' LOOP
            ASSERT digi="0010" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
         WAIT UNTIL clk'EVENT AND clk='1' AND digi(3)='1';
         WHILE digi(3)='1' LOOP
            ASSERT digi="0100" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
         WAIT UNTIL clk'EVENT AND clk='1' AND digi(4)='1';
         WHILE digi(4)='1' LOOP
            ASSERT digi="1000" REPORT "wrong segment" SEVERITY error;
            WAIT UNTIL clk'EVENT AND clk='1';
         END LOOP;
      END PROCEDURE;

      PROCEDURE test2 IS
         TYPE frame IS RECORD
            digi : std_logic_vector(4 DOWNTO 1);
            btn  : std_logic_vector(4 DOWNTO 1);
            dp   : std_logic;
         END RECORD;
         TYPE frames IS ARRAY(natural RANGE <>) OF frame;
         CONSTANT testtab: frames := (
            ("0001", "1111", '0'),
            ("0010", "1111", '0'),
            ("0100", "1111", '0'),
            ("1000", "1111", '0'),

            ("0001", "1110", '1'),
            ("0001", "1101", '0'),
            ("0001", "1011", '0'),
            ("0001", "0111", '0'),

            ("0010", "1110", '0'),
            ("0010", "1101", '1'),
            ("0010", "1011", '0'),
            ("0010", "0111", '0'),

            ("0100", "1110", '0'),
            ("0100", "1101", '0'),
            ("0100", "1011", '1'),
            ("0100", "0111", '0'),

            ("1000", "1110", '0'),
            ("1000", "1101", '0'),
            ("1000", "1011", '0'),
            ("1000", "0111", '1')

         );
         PROCEDURE step (i: natural) IS
         BEGIN
            WAIT UNTIL clk'EVENT AND clk='1' AND digi=testtab(i).digi;
            btn <= testtab(i).btn;
            WAIT UNTIL clk'EVENT AND clk='1';
            ASSERT dp=testtab(i).dp REPORT "wrong decimal point" SEVERITY error;
         END PROCEDURE;
      BEGIN
         REPORT "test2..." SEVERITY note;
         FOR i IN testtab'RANGE LOOP
            step(i);
         END LOOP;
      END PROCEDURE;

      PROCEDURE test3 IS
         TYPE frame IS RECORD
            digi : std_logic_vector(4 DOWNTO 1);
            sw   : std_logic_vector(8 DOWNTO 1);
            seg  : std_logic_vector(7 DOWNTO 1);
         END RECORD;
         TYPE frames IS ARRAY(natural RANGE <>) OF frame;
         CONSTANT testtab: frames := (
            ("0001", "11111111", "0111111" ),
            ("0001", "11111110", "0000110" ),
            ("0001", "11111101", "1011011" ),
            ("0001", "11111100", "1001111" ),

            ("0010", "11111111", "0111111" ),
            ("0010", "11101111", "0000110" ),
            ("0010", "11011111", "1011011" ),
            ("0010", "11001111", "1001111" ),

            ("0100", "11111111", "0111111" ),
            ("0100", "11111110", "0000110" ),
            ("0100", "11111101", "1011011" ),
            ("0100", "11111100", "1001111" ),

            ("1000", "11111111", "0111111" ),
            ("1000", "11101111", "0000110" ),
            ("1000", "11011111", "1011011" ),
            ("1000", "11001111", "1001111" )
         );

         PROCEDURE step (i: natural) IS
         BEGIN
            WAIT UNTIL clk'EVENT AND clk='1' AND digi=testtab(i).digi;
            sw <= testtab(i).sw;
            WAIT UNTIL clk'EVENT AND clk='1';
            ASSERT seg=testtab(i).seg REPORT "wrong segment" SEVERITY error;
         END PROCEDURE;
      BEGIN
         ASSERT FALSE REPORT "test3..." SEVERITY note;
         FOR i IN testtab'RANGE LOOP
            step(i);
         END LOOP;
      END PROCEDURE;
--
--      PROCEDURE test4 IS
--         TYPE frame IS RECORD
--            an   : std_logic_vector(3 DOWNTO 0);
--            sw   : std_logic_vector(7 DOWNTO 0);
--            seg  : std_logic_vector(7 DOWNTO 1);
--         END RECORD;
--         TYPE frames IS ARRAY(natural RANGE <>) OF frame;
--         CONSTANT testtab: frames := (
--            ("0111", "00000001", "0000001"),
--            ("1011", "00000001", "1001111"),
--            ("1101", "00000001", "0000001"),
--            ("1110", "00000001", "1001111"),
--
--            ("0111", "00010010", "1001111"),
--            ("1011", "00010010", "0010010"),
--            ("1101", "00010010", "1001111"),
--            ("1110", "00010010", "0010010"),
--
--            ("0111", "00100011", "0010010"),
--            ("1011", "00100011", "0000110"),
--            ("1101", "00100011", "0010010"),
--            ("1110", "00100011", "0000110"),
--
--            ("0111", "00110100", "0000110"),
--            ("1011", "00110100", "1001100"),
--            ("1101", "00110100", "0000110"),
--            ("1110", "00110100", "1001100"),
--
--            ("0111", "01000101", "1001100"),
--            ("1011", "01000101", "0100100"),
--            ("1101", "01000101", "1001100"),
--            ("1110", "01000101", "0100100"),
--
--            ("0111", "01010110", "0100100"),
--            ("1011", "01010110", "0100000"),
--            ("1101", "01010110", "0100100"),
--            ("1110", "01010110", "0100000"),
--
--            ("0111", "01100111", "0100000"),
--            ("1011", "01100111", "0001111"),
--            ("1101", "01100111", "0100000"),
--            ("1110", "01100111", "0001111"),
--
--            ("0111", "01111000", "0001111"),
--            ("1011", "01111000", "0000000"),
--            ("1101", "01111000", "0001111"),
--            ("1110", "01111000", "0000000"),
--
--            ("0111", "10001001", "0000000"),
--            ("1011", "10001001", "0000100"),
--            ("1101", "10001001", "0000000"),
--            ("1110", "10001001", "0000100"),
--
--            ("0111", "10011010", "0000100"),
--            ("1011", "10011010", "0001000"),
--            ("1101", "10011010", "0000100"),
--            ("1110", "10011010", "0001000"),
--
--            ("0111", "10101011", "0001000"),
--            ("1011", "10101011", "1100000"),
--            ("1101", "10101011", "0001000"),
--            ("1110", "10101011", "1100000"),
--
--            ("0111", "10111100", "1100000"),
--            ("1011", "10111100", "0110001"),
--            ("1101", "10111100", "1100000"),
--            ("1110", "10111100", "0110001")
--         );
--
--         PROCEDURE step (i: natural) IS
--         BEGIN
--            WAIT UNTIL clk'EVENT AND clk='1' AND an=testtab(i).an;
--            sw <= testtab(i).sw;
--            WAIT UNTIL clk'EVENT AND clk='1';
--            ASSERT seg=testtab(i).seg REPORT "wrong segment" SEVERITY error;
--         END PROCEDURE;
--      BEGIN
--         ASSERT FALSE REPORT "test4..." SEVERITY note;
--         FOR i IN testtab'RANGE LOOP
--            step(i);
--         END LOOP;
--      END PROCEDURE;

   BEGIN
--      WAIT UNTIL clk'EVENT AND clk='1' AND rst=(NOT RSTDEF);

      test1;
      test2;
      test3;
 --     test4;

      REPORT "done" SEVERITY note;

      hlt <= '1';
      WAIT;
   END PROCESS;

END verhalten;