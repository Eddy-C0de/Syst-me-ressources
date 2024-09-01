#!/bin/bash

# Configuration
SEUIL_CPU=80       # Seuil CPU en pourcentage
SEUIL_RAM=90       # Seuil RAM en pourcentage
SEUIL_DISQUE=85      # Seuil espace disque en pourcentage
CHECK=60      # Intervalle de vérification en secondes
FICHIER_LOG="system_monitor.log" # Fichier de log pour les rapports

# Adresse e-mail pour les alertes
ALERTE_EMAIL="votre.email@example.com"

# Fonction pour surveiller l'utilisation du CPU
check_cpu_usage() {
    UTILISATION_CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "Utilisation CPU: $UTILISATION_CPU%"
    if (( $(echo "$UTILISATION_CPU > $SEUIL_CPU" | bc -l) )); then
        envoi_alert "CPU" "$UTILISATION_CPU"
    fi
}

# Fonction pour surveiller l'utilisation de la RAM
check_ram_usage() {
    UTILISATION_RAM=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    echo "Utilisation RAM: $UTILISATION_RAM%"
    if (( $(echo "$UTILISATION_RAM > $SEUIL_RAM" | bc -l) )); then
        envoi_alert "RAM" "$UTILISATION_RAM"
    fi
}

# Fonction pour surveiller l'espace disque
check_disk_usage() {
    UTILISATION_DISQUE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    echo "Utilisation espace disque: $UTILISATION_DISQUE%"
    if [ "$UTILISATION_DISQUE" -gt "$SEUIL_DISQUE" ]; then
        envoi_alert "DISK" "$UTILISATION_DISQUE"
    fi
}

# Fonction pour envoyer une alerte par e-mail
envoi_alert() {
    RESSOURCE=$1
    USAGE=$2
    echo "Alerte: Utilisation $RESSOURCE est à $USAGE% !" | mail -s "Alerte de surveillance système" $ALERTE_EMAIL
    echo "$(date): Alerte envoyée pour $RESSOURCE usage à $USAGE%" >> $FICHIER_LOG
}

# Boucle de surveillance
while true; do
    echo "$(date): Début de la vérification des ressources..." >> $FICHIER_LOG
    check_cpu_usage
    check_ram_usage
    check_disk_usage
    echo "$(date): Fin de la vérification des ressources." >> $FICHIER_LOG
    sleep $CHECK
done
