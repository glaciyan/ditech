
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
    
    CONSTANT N: natural := 4;
    SIGNAL cnt: std_logic_vector(0 TO 1);
    SIGNAL cc: std_logic_vector(0 TO 3);
    SIGNAL mux: std_logic_vector(0 TO 3);
    
BEGIN
-- 1-aus-4-Dekoder als Phasengenerator
ena <= cc WHEN rst = NOT RSTDEF ELSE (OTHERS => '0');

mux <= data(3 DOWNTO 0) WHEN cnt(1) = '0' ELSE data(7 DOWNTO 4);

WITH mux SELECT
    seg <= "1111110" WHEN "0000", -- 0
           "0110000" WHEN "0001", -- 1
           "1101101" WHEN "0010", -- 2
           "1111001" WHEN "0011", -- 3
           "0110011" WHEN "0100", -- 4
           "1011011" WHEN "0101", -- 5
           "1011111" WHEN "0110", -- 6
           "1110000" WHEN "0111", -- 7
           "1111111" WHEN "1000", -- 8
           "1111011" WHEN "1001", -- 9
           "1110111" WHEN "1010", -- A
           "0011111" WHEN "1011", -- B
           "1001110" WHEN "1100", -- C
           "0111101" WHEN "1101", -- D
           "1001111" WHEN "1110", -- E
           "1000111" WHEN "1111", -- F
           "0000000" WHEN OTHERS;

WITH cnt SELECT
    cc <= "1000" WHEN "00",
           "0100" WHEN "01",
           "0010" WHEN "10",
           "0001" WHEN "11",
           "0000" WHEN OTHERS;

p1: PROCESS (rst, clk) IS
BEGIN
    IF rst=RSTDEF THEN
        reg <= (OTHERS => '1');
        en <= '0';
        cnt <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
    
        -- Modulo 2^14 Zähler
        IF reg=RES THEN
            en <= '1';
            reg <= (OTHERS => '1');
        ELSE
            en <= '0';
            reg <= lfsr(arg => reg, poly => POLY, din => '0');
        END IF;
        
        -- Modulo-4-Zähler
        IF en = '1' THEN
            IF cnt = N-1 THEN
                cnt <= (OTHERS => '0');
            ELSE
                cnt <= cnt + 1;
            END IF;
        END IF;
    END IF;
    
    
    -- 1-aus-4-Multiplexer
    IF dpin = cc THEN
        dp <= '1';
    ELSE
        dp <= '0';
    END IF;
    
    IF reg(1) = '0' THEN
        
    END IF;

   -- 7-aus-4-Dekoder

   -- 1-aus-4-Multiplexer
END PROCESS;
END struktur;