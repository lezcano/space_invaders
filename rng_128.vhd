----------------------------------------------------------------------------------
-- -Hecho por Daniel Báscones García
-- 
-- Generador aleatorio de números de 32 bits. 
-- Este método garantiza una alta calidad en los números aleatorios además de 
-- tener un periodo de 2^128-1
--
-- Reset asíncrono con inicialización de la semilla. Recorre todos los números
-- posibles de 32 bits con periodo 2^128-1 excepto el 0x00000000, que no puede
-- usarse como semilla.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rng_128 is
	port (
		clk, reset: in std_logic;
		seed: in std_logic_vector(127 downto 0);
		rnumber: out std_logic_vector(31 downto 0)
	);
end rng_128;

architecture Behavioral of rng_128 is

	signal data: std_logic_vector(127 downto 0);
	
	signal temp, nextbits: std_logic_vector(31 downto 0);
	
begin

	--  t = x ^ (x << 11);
	--  x = y; y = z; z = w;
	--  return w = w ^ (w >> 19) ^ (t ^ (t >> 8));
	
	temp		<= data(127 downto 96) xor 
					(data(116 downto 96) & "00000000000");
	nextbits <=	data(31 downto 0) xor 
					("0000000000000000000" & data(31 downto 19)) xor 
					(temp xor ("00000000" & temp(31 downto 8)));
				

	update: process(clk, reset, seed)
	begin
		if reset = '1' then
			data <= seed;
		elsif rising_edge(clk) then
			data <= data(95 downto 0) & nextbits;
		end if;
	end process;
	
	rnumber	<= data(31 downto 0);
end Behavioral;

