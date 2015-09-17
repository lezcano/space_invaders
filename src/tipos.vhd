library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--la pantalla tiene (x,y) = 380x527 pixels 

package tipos is

-- Constantes Generales

-- Constantes tamaño arrays

-- Tamaños de los arrays
-- Estos tamaños indican el número máximo de elementos de los mismos
constant tam_h_counter: integer := 9;
constant tam_v_counter: integer := 10;
constant tam_rgb: integer := 9;
constant tam_indice_array: integer := 6;

-- Tamaños a falta de ajustar con los reales
constant min_screen_x: integer := 30;
constant max_screen_x: integer := 250;

constant min_screen_y: integer := 70;
constant max_screen_y: integer := 380;

-- Tamaño Entero Pequeño
constant small_int: integer:= 6;

-- Tipos Generales
subtype horizontal_counter is std_logic_vector (tam_h_counter-1 downto 0);
subtype vertical_counter is std_logic_vector (tam_v_counter-1 downto 0);
subtype color_rgb is std_logic_vector (tam_rgb-1 downto 0);
subtype t_small_int is std_logic_vector (small_int-1 downto 0);

--Tipos teclado
type accion is (ARRIBA, IZQUIERDA, ABAJO, DERECHA, DISPARAR, INTRO, NADA);

-- Color Fondo
constant color_fondo: color_rgb := "000000000";
-- Estados Codificador de Prioridad
type estado_cod is (ENCONTR, NOENCONTR);

type estados_juego is (INIT_SCR, LEVEL1, LEVEL2, SET_LEVEL, YOUR_LEVEL, WIN, LOSE);

type estado_flecha is (FLECHA_LVL_1, FLECHA_LVL_2, FLECHA_SET_LVL);

-----------------------
--- MARCIANOS
-----------------------
-- Tamaño Marciano
constant tam_marc_x: integer := 16;
constant semi_tam_marc_x: integer :=7; --no es exactamente la mitad del tam_marc_x; Es (tam_marc_x-tam_laser)/2
constant tam_marc_y: integer := 32;

-- Numero de Marcianos
constant filas_marc: integer:= 3;
constant columnas_marc: integer:= 6;
constant log_columnas_marc: integer:= 3;--ceil del log de columnas marc
constant log_filas_marc: integer:= 2;--ceil del log de filas marc

-- Constante Forma de la Fase
type colores_marc is (L, M, H);
type vector_id_colors is array (columnas_marc-1 downto 0) of  colores_marc;
type matriz_id_color is array (filas_marc-1 downto 0) of vector_id_colors;


--Numero laseres marciano
constant num_laser_marc: integer:= 5;

-- Velocidad Marcianos
constant marc_vel: integer:= 6;
constant marc_vel_bajada: integer:= 8;

-- Tipos Marcianos
type matriz_tam_marc is array (filas_marc -1 downto 0) of std_logic_vector (columnas_marc-1 downto 0);
type dir_marc is(DERECHA, IZQUIERDA, ABAJO, DESACTIVADO);
type v_small_int_columnas is array (columnas_marc-1 downto 0) of t_small_int; 

-- Constantes Matrices Marcianos
type t_vector_pos_x is array (columnas_marc-1 downto 0) of horizontal_counter;
type t_vector_pos_y is array (filas_marc-1 downto 0) of vertical_counter;

constant vector_ini_x: t_vector_pos_x := (conv_std_logic_vector(70, tam_h_counter),
														conv_std_logic_vector(90, tam_h_counter),
														conv_std_logic_vector(110, tam_h_counter),
														conv_std_logic_vector(130, tam_h_counter),
														conv_std_logic_vector(150, tam_h_counter),
														conv_std_logic_vector(170, tam_h_counter));
constant vector_ini_y: t_vector_pos_y := (conv_std_logic_vector(80, tam_v_counter),
														conv_std_logic_vector(120, tam_v_counter),
														conv_std_logic_vector(160, tam_v_counter));
														

-- Barrera
constant filas_barrera : integer := 8;
constant columnas_barrera : integer := 16;
constant tam_barrera_x: integer := 32;
constant tam_barrera_y: integer := 16;

-- Constantes Nave
constant tam_nave_x: integer := 16;
constant tam_nave_y: integer := 16;
constant semi_tam_nave_x: integer := 7;
constant nave_speed: integer := 3;

-- Constantes Laser
constant tam_laser_x: integer := 2;
constant tam_laser_y: integer := 10;
constant laser_color: color_rgb := "111111111"; -- Color no definitivo morado_laser:"010100110"

--Posiciones y tamaño de las marcas de las vidas de la nave
constant pos_vida1_x: horizontal_counter:=conv_std_logic_vector (224,tam_h_counter);
constant pos_vida2_x: horizontal_counter:=conv_std_logic_vector (234,tam_h_counter);
constant pos_vida3_x: horizontal_counter:=conv_std_logic_vector (244,tam_h_counter);
constant pos_vida_y: vertical_counter:=conv_std_logic_vector (390,tam_h_counter);
constant tam_vida_nave_x: integer:=6;
constant tam_vida_nave_y: integer:=12;

-- Marcador
constant tam_numero_x: integer := 8;
constant tam_numero_y: integer := 14;
constant ancho_segm : integer := 2;
constant largo_segm : integer := 4;
constant inicio_marcador_v: vertical_counter := conv_std_logic_vector(30, tam_v_counter);
constant inicio_marcador_h: horizontal_counter := conv_std_logic_vector(30, tam_h_counter);
constant inicio_marcador_v_pant_ini: vertical_counter := conv_std_logic_vector(100, tam_v_counter);
constant inicio_marcador_h_pant_ini: horizontal_counter := conv_std_logic_vector(200, tam_h_counter);
constant color_marcador: color_rgb := "111111111";

type pair_v is array (columnas_marc - 1 downto 0) of std_logic_vector(1 downto 0);
type pair_matrix is array (filas_marc - 1 downto 0) of pair_v;

end tipos;

package body tipos is


end tipos;