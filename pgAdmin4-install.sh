#!/bin/bash

set -euo pipefail

version_instalador=1.0
fecha_version="13/01/2026"
nombre_usuario=$(whoami)
version_pgadmin=9.11
SECONDS=0
#Directorios
path=$(pwd)
path_entorno="$path/environments/my_env"



echo -e "\e[33m"
echo "	██████╗  ██████╗  █████╗ ██████╗ ███╗   ███╗██╗███╗   ██╗    ██╗  ██╗ ";
echo "	██╔══██╗██╔════╝ ██╔══██╗██╔══██╗████╗ ████║██║████╗  ██║    ██║  ██║ ";
echo "	██████╔╝██║  ███╗███████║██║  ██║██╔████╔██║██║██╔██╗ ██║    ███████║ ";
echo "	██╔═══╝ ██║   ██║██╔══██║██║  ██║██║╚██╔╝██║██║██║╚██╗██║    ╚════██║ ";
echo "	██║     ╚██████╔╝██║  ██║██████╔╝██║ ╚═╝ ██║██║██║ ╚████║         ██║ ";
echo "	╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝         ╚═╝ ";
echo "	                                                                      ";
echo "	██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ ";
echo "	██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗";
echo "	██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝";
echo "	██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗";
echo "	██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║";
echo "	╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝";
echo -e "Versión: $version_instalador"
echo -e "Fecha versión: $fecha_version"
echo -e "By: Héctor Monroy Fuertes"
echo -e "GitHub: https://www.github.com/HectorCRM"
echo -e "********************************************************"
echo
sleep 2

echo -e "¡Hola $nombre_usuario!" 
sleep 1
echo "Este instalador descargará de forma automatica pgAdmin 4 en su última versión, $version_pgadmin a fecha del desarrollo de este script"
sleep 1
echo "Iniciando instalacion"
sleep 1

echo -e "Comprobando conexión a internet...\e[39m"
sleep 2

if ping -c 1 -W 2 github.com > /dev/null; then
		echo -e "\e[32m¡Conexión correcta! \e[39m"
	else 
		while ! ping -c 1 -W 2 github.com > /dev/null; do
			echo -e "\e[31m No hay conexión a internet o www.github.com no funciona. \e[39m"
			echo -e "\e[31m Revisa la conexión a internet. \e[39m"
			read -rp " ¿Intentar de nuevo?[s/n]: " reintento
		
			if [[ $reintento == [sS] ]]; then
				echo "Reintentado la conexión..."
				sleep 2
			else 
				echo -e "\e[31m Abortando instalación... \e[39m"
				sleep 2
				exit 1
			fi
		done
		echo -e "\e[32m Conexión reestablecida con éxito. \e[39m"
	fi
	sleep 2


echo
echo -e "\e[33mActualizando el sistema... \e[39m"
sleep 1
sudo apt update -y

echo -e "\e[33mInstalando dependencias necesarias para pgAdmin 4...\e[39m"
sleep 2
sudo apt install libgmp3-dev python3-venv libpq-dev apache2 libapache2-mod-wsgi-py3 -y

#CREACIÓN DE LOS DIRECTORIOS NECESARIOS PARA PGADMIN Y APACHE
echo
echo -e "\e[33mCreando directorios para almacenar datos de pgAdmin...\e[39m"
sleep 2
sudo mkdir -p /var/log/pgadmin4
sudo mkdir -p /var/lib/pgadmin4/sessions
sudo mkdir -p /var/lib/pgadmin4/storage
sudo mkdir -p /var/lib/pgadmin4/azure_cache
sudo mkdir -p /etc/apache2/sites-available

sudo touch /var/log/pgadmin4/pgadmin4.log

#CAMBIO PROPIEDAD DIRECTORIOS AL USUARIO
echo
echo -e "\e[33mCambiando la propiedad de los directorios al usuario $nombre_usuario \e[39m"
sleep 2
sudo chown -R $nombre_usuario:$nombre_usuario /var/lib/pgadmin4 /var/log/pgadmin4 /var/lib/pgadmin4/azure_cache
 
sudo chmod -R 770 /var/lib/pgadmin4 /var/log/pgadmin4

#ENTORNO VIRTUAL CON PYTHON-VENV
echo -e "\e[32m Configurando entorno virtual... \e[39m"
sleep 2
mkdir -p "$path/environments"
cd "$path/environments"
python3 -m venv my_env && source $path_entorno/bin/activate

if [[ "$VIRTUAL_ENV" != "" ]]; then
	echo
    echo -e "\e[32m¡Entorno virtual activado con éxito! \e[39m"
    sleep 2
else
    echo -e "\e[31m¡Error al activar el entorno virtual.! \e[39m"
    sleep 3
    exit 1
fi

#DESCARGA DE PGADMIN DESDE LA PÁGINA OFICIAL
echo
echo -e "\e[33m Descargando versión $version_pgadmin de pgAdmin4...\e[39m"
sleep 2
wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.11/pip/pgadmin4-9.11-py3-none-any.whl

echo
echo -e "\e[33mInstalando wheel...\e[39m"
sleep 2
python -m pip install wheel || true

echo
echo -e "\e[33m Instalando pgAdmin4 $version_pgadmin... \e[39m"
sleep 2
python -m pip install pgadmin4-9.11-py3-none-any.whl

path_python=$("$path_entorno/bin/python3" -c "import site; print(site.getsitepackages()[0])")
path_pgadmin="${path_python}/pgadmin4"

if [ ! -d "$path_pgadmin" ]; then
    echo -e "\e[31mERROR: No se encuentra la carpeta de pgAdmin en $path_pgadmin \e[39m"
    exit 1
fi
echo

#CONFIGURACIÓN DE PGADMIN
echo
echo -e "\e[33mCreando archivo de configuración.... \e[39m"
sleep 2
#Creación del archivo config_local.py
cat <<EOF >  "$path_pgadmin/config_local.py"
LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'
SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'
SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'
STORAGE_DIR = '/var/lib/pgadmin4/storage'
AZURE_CREDENTIAL_CACHE_DIR = '/var/lib/pgadmin4/azure_cache'
SERVER_MODE = True
MASTER_PASSWORD_REQUIRED = False
EOF

echo
echo -e "\e[33mConfigurando base de datos... \e[39m"
sleep 2
cd "$path_entorno"


export PYTHONPATH="$path_python"

echo

if "$path_entorno/bin/python3" "$path_pgadmin/setup.py" setup-db; then
    echo -e "\e[32m¡Configuración automática exitosa!\e[39m"
    sleep 1
elif "$path_entorno/bin/python3" -m pgadmin4.setup setup.db; then
    echo -e "\e[32m¡Configuración automática(vía modulo) exitosa! \e[39m"
    sleep 1
else
	echo -e "\e[31m¡Configuración fallida!\e[39m"
	sleep 2
	echo -e "\e[31mAbandonando configuración...\e[39m"
	sleep 2
	exit 1
fi


echo -e "\e[32mAbandonando entorno virtual... \e[39m"
sleep 2
deactivate


#TRASPASO DE PERMISOS A APACHE
sudo chown -R www-data:www-data /var/lib/pgadmin4/
sudo chown -R www-data:www-data /var/log/pgadmin4/
sudo chmod o+x "/home/$nombre_usuario"
sudo chmod -R 755 "$path_entorno"

#CONFIGURACION DEL SERVIDOR WEB DE APACHE
echo -e "\e[33mCreando archivo de configuración para el host virtual del servidor... \e[39m"
ip=$(hostname -I | awk '{print $1}')

#Creación del archivo pgadmin4.conf
cat <<EOF | sudo tee /etc/apache2/sites-available/pgadmin4.conf > /dev/null
<VirtualHost *:80>
    ServerName $ip

    WSGIDaemonProcess pgadmin processes=1 threads=25 python-home=$path_entorno
    WSGIScriptAlias /pgadmin4 $path_pgadmin/pgAdmin4.wsgi

    <Directory "$path_pgadmin">
        WSGIProcessGroup pgadmin
        WSGIApplicationGroup %{GLOBAL}
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF


echo -e "\e[33mDeshabilitando el host predeterminado de Apache... \e[39m"
sleep 1
sudo a2dissite 000-default.conf > /dev/null 2>&1


echo -e "\e[33mHabilitando la configuración en Apache... \e[39m"
sleep 1
sudo a2enmod wsgi
sudo a2ensite pgadmin4.conf

echo -e "\e[33mValidando sintaxis pgadmin.conf \e[39m"
sleep 2
apachectl configtest

echo -e "\e[33mReiniaciando servicio de Apache... \e[33m"
sleep 2
sudo systemctl restart apache2

#rm pgadmin4-9.11-py3-none-any.whl

echo -e "\e[32m¡Proceso completado!"
echo -e "Recuerda que puedes acceder a pgAdmin desde http://$ip/pgadmin4 \e[39m"
firefox http://$ip/pgadmin4 &

printf "El proceso completo tardado: %02d:%02d\n"  $((SECONDS%3600/60)) $((SECONDS%60))
read -rp "Pulsa 'enter' para terminar"

