
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      active high
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        ena:   OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable  signals,                active high
        seg:   OUT std_logic_vector( 7 DOWNTO 1);   -- 7 connections to seven-segment display, active high
        dp:    OUT std_logic);                      -- decimal point output,                   active high
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS
    CONSTANT RES: std_logic_vector := "11111111111111";
    
    SIGNAL reg: std_logic_vector(13 DOWNTO 0);
    SIGNAL dff: std_logic;
BEGIN
p1: PROCESS (rst, clk) IS
BEGIN
    dp <= dff;

    IF rst=RSTDEF THEN
        dff <= '0';
        reg <= (OTHERS => '1');
    ELSIF rising_edge(clk) THEN
        IF reg=RES THEN
            dff <= NOT dff;
            reg <= (OTHERS => '1');
        ELSE
            -- Modulo-2**14-Zaehler
            -- x^14 + x^10 + x^6 + x^1 + 1
            reg <= (reg(13) xor reg(7) xor reg(5) xor reg(0)) & reg(13 DOWNTO 1);
            --reg(13 DOWNTO 7) <= reg(12 DOWNTO 6);    -- Shift bits 13 to 7
            --reg(6) <= reg(5) xor reg(13);            -- Apply feedback for tap at position 6
            --reg(5) <= reg(4);                        -- Shift bit 5
            --reg(4) <= reg(3);                        -- Shift bit 4
            --reg(3) <= reg(2);                        -- Shift bit 3
            --reg(2) <= reg(1) xor reg(13);            -- Apply feedback for tap at position 2
            --reg(1) <= reg(0) xor reg(13);            -- Apply feedback for tap at position 1
            --reg(0) <= reg(13);                       -- Feedback from position 13
        END IF;
    END IF;
    
    
    
  

   
   -- Modulo-4-Zaehler

   -- 1-aus-4-Dekoder als Phasengenerator
       
   -- 1-aus-4-Multiplexer

   -- 7-aus-4-Dekoder

   -- 1-aus-4-Multiplexer
END PROCESS;
END struktur;