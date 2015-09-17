library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity cod_prior_marc is
	generic (
		width: integer := 8
	);
	port (
		arr: in std_logic_vector (width-1 downto 0);
		num_disp: in t_small_int;
		
		encontrado: out std_logic; 			-- 1 si hay alguno que este a 1
		pos_primer: out t_small_int;
		pos_ult: out t_small_int;
		num_activ: out t_small_int;
		pos_disp: out t_small_int
	);
end cod_prior_marc;

architecture cod_prior_marc_arch of cod_prior_marc is

	component celda_cod_prior_marc is
		port(
			X: in std_logic;
			
			position: in t_small_int;	
		
			num_disp: in t_small_int;
		
			encontr_primer: in std_logic;
			encontr_pos_disp: in std_logic;
			pos_prim_ant: in t_small_int;
			pos_ult_ant: in t_small_int;
			num_activ_ant: in t_small_int;
			pos_disp_ant: in t_small_int;
			
			encontr_primer_sig: out std_logic;
			encontr_pos_disp_sig: out std_logic;
			pos_prim_sig: out t_small_int;
			pos_ult_sig: out t_small_int;
			num_activ_sig: out t_small_int;
			pos_disp_sig: out t_small_int
		);
	end component celda_cod_prior_marc;

	type v_small_int is array (width-1 downto 0) of t_small_int;
	
	signal v_pos_prim: v_small_int;
	signal v_pos_ult: v_small_int;
	signal v_num_activ: v_small_int;
	signal v_pos_disp: v_small_int;
	signal v_encontr:  std_logic_vector (width -1 downto 0);
	signal v_encontr_pos_disp:  std_logic_vector (width -1 downto 0);
	
begin
	c0: celda_cod_prior_marc port map (
					x => arr(0), 
					
					position => (others => '0'), 
					
					num_disp => num_disp, 
					
					encontr_primer => '0', 
					encontr_pos_disp=> '0', 
					pos_prim_ant => (others => '0'),
					pos_ult_ant => (others => '0'), 
					num_activ_ant => (others => '0'), 
					pos_disp_ant => (others => '0'),
					
					encontr_primer_sig => v_encontr (0), 
					encontr_pos_disp_sig => v_encontr_pos_disp (0),
					pos_prim_sig => v_pos_prim (0), 
					pos_ult_sig => v_pos_ult (0), 
					num_activ_sig => v_num_activ(0), 
					pos_disp_sig => v_pos_disp(0) 
				);
				
	gen_celdas: for i in 1 to width-1 generate
		ck: celda_cod_prior_marc port map (											
					x => arr(i), 
					
					position => conv_std_logic_vector(i, small_int), 
					
					num_disp => num_disp,
					
					encontr_primer => v_encontr(i-1),
					encontr_pos_disp=> v_encontr_pos_disp (i-1),
					pos_prim_ant => v_pos_prim(i-1), 
					pos_ult_ant => v_pos_ult(i-1),  
					num_activ_ant => v_num_activ(i-1),
					pos_disp_ant => v_pos_disp (i-1), 
					
					encontr_primer_sig => v_encontr (i), 
					encontr_pos_disp_sig => v_encontr_pos_disp (i),
					pos_prim_sig => v_pos_prim (i), 
					pos_ult_sig => v_pos_ult (i), 
					num_activ_sig => v_num_activ(i), 
					pos_disp_sig => v_pos_disp(i) 
				);
										
	end generate gen_celdas;
	
	pos_disp <= v_pos_disp (width -1);
	
	encontrado <= v_encontr (width - 1);
	with v_encontr (width - 1) select
	pos_primer <= 	v_pos_prim (width - 1) when '1',
						(others => '0') when others;
	with v_encontr (width - 1) select
	pos_ult <= 	v_pos_ult (width - 1) when '1',
					(others => '0') when others;
	num_activ <= v_num_activ (width - 1);
					
	
end cod_prior_marc_arch;

