
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
    SIGNAL reg: std_logic_vector(14 DOWNTO 0);

    CONSTANT N: natural := 4;
    SIGNAL cnt: std_logic_vector(0 TO 1);
    SIGNAL cc: std_logic_vector(0 TO 3);
    SIGNAL mux: std_logic_vector(0 TO 3);
BEGIN
-- 1-aus-4-Dekoder als Phasengenerator
ena <= cc WHEN rst = NOT RSTDEF ELSE (OTHERS => '0');

-- 7-aus-4-4bit mux
WITH cnt SELECT
    mux <= data(15 DOWNTO 12) WHEN "00",
           data(11 DOWNTO 8)  WHEN "01",
           data(7 DOWNTO 4)   WHEN "11",
           data(3 DOWNTO 0)   WHEN "10",
           "0000"             WHEN OTHERS;

-- 7-aus-4 Decoder
WITH mux SELECT
    seg <= "0111111" WHEN "0000", -- 0
           "0000110" WHEN "0001", -- 1
           "1011011" WHEN "0010", -- 2
           "1001111" WHEN "0011", -- 3
           "1100110" WHEN "0100", -- 4
           "1101101" WHEN "0101", -- 5
           "1111101" WHEN "0110", -- 6
           "0000111" WHEN "0111", -- 7
           "1111111" WHEN "1000", -- 8
           "1101111" WHEN "1001", -- 9
           "1110111" WHEN "1010", -- A
           "1111100" WHEN "1011", -- B
           "0111001" WHEN "1100", -- C
           "1011110" WHEN "1101", -- D
           "1111001" WHEN "1110", -- E
           "1110001" WHEN "1111", -- F
           "0000000" WHEN OTHERS;

-- 1-aus-4 Decoder
WITH cnt SELECT
    cc <= "1000" WHEN "00",
          "0100" WHEN "01",
          "0010" WHEN "11",
          "0001" WHEN "10",
          "0000" WHEN OTHERS;

-- 1-aus-4 Mux
dp <= (dpin(0) and cc(3)) or 
      (dpin(1) and cc(2)) or
      (dpin(2) and cc(1)) or
      (dpin(3) and cc(0));

-- Frequenzteiler
p1: PROCESS (rst, clk) IS
BEGIN
    IF rst=RSTDEF THEN
        reg <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
        -- Modulo 2^14 Zaehler
        reg <= ('0' & reg(13 DOWNTO 0)) + 1;
    END IF;
END PROCESS;

-- Modulo-4-Zaehler
counter: PROCESS (rst, clk) IS
BEGIN
    IF rst=RSTDEF THEN
        cnt <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
        IF reg(14) = '1' THEN
            -- gray code counter
            CASE cnt IS
                WHEN "00" =>
                    cnt <= "01";
                WHEN "01" =>
                    cnt <= "11";
                WHEN "11" =>
                    cnt <= "10";
                WHEN "10" =>
                    cnt <= "00";
                WHEN OTHERS =>
                    cnt <= "00";
            END CASE;
        END IF;
    END IF;
END PROCESS;
END struktur;