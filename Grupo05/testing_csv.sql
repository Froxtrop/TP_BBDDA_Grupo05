/*	 ___                     _            _                              _       
	|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
	 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
	 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
	|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
                          |_|                                                
*/
EXEC socios.cargar_responsables_de_pago_csv_sp
     @ruta_archivo = 'C:\Users\Usuario\Documents\Proyectos\TP_BBDDA_Grupo05\Archivos\Responsables-de-Pago.csv'; 
GO
SELECT * FROM socios.socio

/*		 ___                     _            _                              _       
		|_ _|_ __  ___  ___ _ __(_)_ __   ___(_) ___  _ __    ___  ___   ___(_) ___  
		 | || '_ \/ __|/ __| '__| | '_ \ / __| |/ _ \| '_ \  / __|/ _ \ / __| |/ _ \ 
		 | || | | \__ \ (__| |  | | |_) | (__| | (_) | | | | \__ \ (_) | (__| | (_) |
		|___|_| |_|___/\___|_|  |_| .__/ \___|_|\___/|_| |_| |___/\___/ \___|_|\___/ 
		 _ __ ___   ___ _ __   ___|_| __                                             
		| '_ ` _ \ / _ \ '_ \ / _ \| '__|                                            
		| | | | | |  __/ | | | (_) | |                                               
		|_| |_| |_|\___|_| |_|\___/|_|                                               
*/

EXEC socios.cargar_grupo_familiar_csv_sp
     @ruta_archivo = 'C:\Users\Usuario\Documents\Proyectos\TP_BBDDA_Grupo05\Archivos\Grupo-Familiar.csv'; 
GO
SELECT * FROM socios.Parentesco;

/*
     _        _     _                  _       
    / \   ___(_)___| |_ ___ _ __   ___(_) __ _ 
   / _ \ / __| / __| __/ _ \ '_ \ / __| |/ _` |
  / ___ \\__ \ \__ \ ||  __/ | | | (__| | (_| |
 /_/   \_\___/_|___/\__\___|_| |_|\___|_|\__,_|
                                               
*/
EXEC socios.cargar_asistencia_actividad_csv_sp
	@ruta_archivo = 'C:\Users\Usuario\Documents\Proyectos\TP_BBDDA_Grupo05\Archivos\presentismo-actividades.csv';
GO
SELECT * FROM socios.AsistenciaActividadDeportiva;