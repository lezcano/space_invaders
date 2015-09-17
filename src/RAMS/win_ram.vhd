library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use std.textio.all;

entity win_ram is
       port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(12 downto 0);--flecha de 64x128
			 
          do1 :	out std_logic_vector(8 downto 0)
	);
end win_ram;

architecture circuito  of win_ram is
	-- El tipo ram es un array con capacidad para todos los valores que conforman la imagen .data
   --	Tipos de la RAM
	-- 1024 = 32x32
	type RamType is array(0 to 8191) of bit_vector(8 downto 0);
	
	-- Funcion que rellena de datos la RAM
	impure function InitRamFromFile (RamFileName : in string) return RamType is	
		FILE RamFile : text is in RamFileName;
		variable RamFileLine : line;
		variable RAM : RamType;
	
		begin
		for I in RamType'range loop
			readline (RamFile, RamFileLine);
			read (RamFileLine, RAM(I));
		end loop;
		return RAM;														-- Devuelve una RAM llena con los datos del archivo que le 
	end function;
	signal RAM : RamType := InitRamFromFile("win.data");
	-- Se supone que aquí ya están los datos dentro de la RAM
	
begin

   puerto1: process (clk)
	begin
        if rising_edge(clk) then
            do1 <= to_stdlogicvector(RAM(conv_integer(addr1)));
        end if;
    end process puerto1;
end circuito;
