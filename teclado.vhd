-- Teclado que devuelve el tipo de estado de en el que entrara la nave si se toca la tecla adecuada o el estado 'nada'

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;


entity teclado_reg is
	port(
			entrada: in std_logic;
			clk: in std_logic;
			reset: in std_logic;
			tecla: out accion
		);
end teclado_reg;

architecture teclado_arch of teclado_reg is

type estado is (ENVIAR, DESECHAR);
--Constantes teclado
constant tamReg: natural:= 11;
constant w_key: std_logic_vector (7 downto 0) := X"1D";
constant a_key: std_logic_vector (7 downto 0) := X"1C";
constant s_key: std_logic_vector (7 downto 0) := X"1B";
constant d_key: std_logic_vector (7 downto 0) := X"23";
constant spaceBar_key: std_logic_vector (7 downto 0) := X"29";
constant intro_key: std_logic_vector (7 downto 0) := X"5A";
	
--Señales teclado
signal registro : std_logic_vector (tamReg-1 downto 0);
signal reg_salida: std_logic_vector (tamReg-1 downto 0);
signal cont11, sig_cont11: std_logic_vector (3 downto 0);
signal est, sig_est: estado;

begin

recibirDato: process (clk, reset)
begin
	if reset = '1' then  
		registro <= (others => '0');
		est <= ENVIAR;
		cont11 <= (others => '0');
	elsif clk'event and clk = '0' then 			
		registro <= entrada & registro (tamReg-1 downto 1);
		cont11 <= sig_cont11;
		est <= sig_est;
	end if;
end process recibirDato;

actualizar_reg: process (est, cont11, registro)
begin
	if est = ENVIAR and cont11 = "0000" then 
		reg_salida <= registro; -- Posible latch
	end if;
end process;

aum_cont: process (cont11)
begin
	if cont11 = "1010" then
		sig_cont11 <= (others => '0');
	else
		sig_cont11 <= cont11 + 1;
	end if;
end process;

act_est: process (cont11, registro, est)
begin
	if cont11 = "0000" then
		if registro (tamReg-3 downto 1) = X"F0" then
			sig_est <= DESECHAR;
		else
			sig_est <= ENVIAR;
		end if;
	else
		sig_est <= est;
	end if;
end process;


with reg_salida (tamReg-3 downto 1) select
tecla <= ARRIBA when w_key,
			IZQUIERDA when a_key,
			ABAJO when s_key,
			DERECHA when d_key,
			DISPARAR when spaceBar_key,
			INTRO when intro_key,
			NADA when others;
			
end teclado_arch;