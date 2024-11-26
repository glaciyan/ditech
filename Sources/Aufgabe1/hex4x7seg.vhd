
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.lfsr_lib.ALL;

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
    -- x^14 + x^10 + x^6 + x^1 + 1
    CONSTANT POLY: std_logic_vector := "100010001000011";
    
    CONSTANT RES: std_logic_vector := exec(poly => POLY, size => 1666);
    -- CONSTANT RES: std_logic_vector := "00111111110011";
    
    SIGNAL reg: std_logic_vector(13 DOWNTO 0);
    SIGNAL en: std_logic;
BEGIN
p1: PROCESS (rst, clk) IS
BEGIN
    IF rst=RSTDEF THEN
        reg <= (OTHERS => '1');
        en <= '0';
    ELSIF rising_edge(clk) THEN
        IF reg=RES THEN
            en <= '1';
            reg <= (OTHERS => '1');
        ELSE
            en <= '0';
            reg <= lfsr(arg => reg, poly => POLY, din => '0');
        END IF;
    END IF;
    
    
    
  

   
   -- Modulo-4-Zaehler

   -- 1-aus-4-Dekoder als Phasengenerator
       
   -- 1-aus-4-Multiplexer

   -- 7-aus-4-Dekoder

   -- 1-aus-4-Multiplexer
END PROCESS;
END struktur;