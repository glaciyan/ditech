LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY blink IS
  PORT(rst:  IN  std_logic;  -- reset, low active
       clk:  IN  std_logic;  -- clock, rising edge active
       led:  OUT std_logic;  -- led, high active
       tmp:  OUT std_logic);  --
END blink;

ARCHITECTURE verhalten OF blink IS
   
  CONSTANT RSTDEF: std_logic := '0';  
  CONSTANT RES: std_logic_vector := "01111110101011001111010110";
 
  SIGNAL   reg: std_logic_vector(25 DOWNTO 0);
  SIGNAL   dff: std_logic;
   
BEGIN

  led <= dff;
  tmp <= '0';

  p1: PROCESS (rst, clk) IS
  BEGIN
     IF rst=RSTDEF THEN
       dff <= '0';
       reg <= (OTHERS => '1');
     ELSIF rising_edge(clk) THEN
       IF reg=RES THEN
         dff <= NOT dff;
         reg <= (OTHERS => '1');
       ELSE
         -- Polynom: x^26 + x^6 + x^2 + x^1 + 1
         reg(25 DOWNTO 7) <= reg(24 DOWNTO 6);
         reg(6) <= reg(5) XOR reg(25);
         reg(5) <= reg(4);
         reg(4) <= reg(3);
         reg(3) <= reg(2);
         reg(2) <= reg(1) XOR reg(25);
         reg(1) <= reg(0) XOR reg(25);
         reg(0) <= reg(25);
       END IF;
    END IF;
  END PROCESS;

END verhalten;