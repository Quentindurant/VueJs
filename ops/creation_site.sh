#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           🚀  DEPLOYER PRO  v3.1                             ║
# ║  static │ vue │ node │ laravel │ docker                      ║
# ║  Nginx · PM2 · Docker · SSL · Backup · Rollback              ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Palette ────────────────────────────────────────────────────
GREEN='\033[1;32m'; BLUE='\033[1;34m';   YELLOW='\033[1;33m'
RED='\033[1;31m';   PURPLE='\033[1;35m'; CYAN='\033[1;36m'
BOLD='\033[1m';     DIM='\033[2m';       RESET='\033[0m'

# ── État global ────────────────────────────────────────────────
START_TIME=$(date +%s)
STEP_START=$START_TIME
CURRENT_STEP=0
TOTAL_STEPS=13
DEPLOY_SUCCESS=false
BACKUP_PATH=""
WEB_DIR=""
WEB_ROOT=""
APP_PORT=3001
PROJECT_TYPE=""

# ══════════════════════════════════════════════════════════════
#  FONCTIONS VISUELLES
# ══════════════════════════════════════════════════════════════

_elapsed_step()  { echo "$(( $(date +%s) - STEP_START ))s"; }
_elapsed_total() {
  local s=$(( $(date +%s) - START_TIME ))
  printf "%dm%02ds" $(( s/60 )) $(( s%60 ))
}

progress_bar() {
  local cur=$1 tot=$2 w=40
  local filled=$(( cur * w / tot ))
  local empty=$(( w - filled ))
  local pct=$(( cur * 100 / tot ))
  printf "  ${GREEN}"
  for ((i=0; i<filled; i++)); do printf "█"; done
  printf "${DIM}"
  for ((i=0; i<empty; i++)); do printf "░"; done
  printf "${RESET}  ${BOLD}%3d%%${RESET}  ${DIM}(%d/%d)${RESET}\n" "$pct" "$cur" "$tot"
}

step() {
  [ "$CURRENT_STEP" -gt 0 ] && \
    printf "  ${DIM}⏱  terminé en %s${RESET}\n" "$(_elapsed_step)"
  CURRENT_STEP=$1
  STEP_START=$(date +%s)
  echo ""
  echo -e "${BLUE}╔══════════════════════════════════════════════╗${RESET}"
  printf  "${BLUE}║${RESET}  ${BOLD}[%s/%s]${RESET}  %-38s${BLUE}║${RESET}\n" \
    "$CURRENT_STEP" "$TOTAL_STEPS" "$2"
  echo -e "${BLUE}╚══════════════════════════════════════════════╝${RESET}"
  progress_bar "$CURRENT_STEP" "$TOTAL_STEPS"
  echo ""
}

success() { echo -e "  ${GREEN}✔${RESET}  $1"; }
warning() { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
info()    { echo -e "  ${CYAN}ℹ${RESET}  $1"; }
skip()    { echo -e "  ${DIM}↷${RESET}  ${DIM}Ignoré : $1${RESET}"; }
error()   {
  echo -e "\n  ${RED}╔══════════════════════════════╗${RESET}"
  echo -e   "  ${RED}║  ✖  ERREUR FATALE            ║${RESET}"
  echo -e   "  ${RED}╚══════════════════════════════╝${RESET}"
  echo -e   "  ${RED}$1${RESET}\n"
  exit 1
}

spinner() {
  local msg="$1"; shift
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  ("$@") > /tmp/_deploy_out 2>&1 &
  local pid=$! i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}%s${RESET}  %s" "${frames[$i]}" "$msg"
    i=$(( (i+1) % 10 )); sleep 0.1
  done
  wait "$pid"; local rc=$?
  printf "\r%-60s\r" " "
  [ $rc -eq 0 ] && success "$msg" || { cat /tmp/_deploy_out; error "$msg — voir les logs ci-dessus"; }
}

# ══════════════════════════════════════════════════════════════
#  ROLLBACK AUTOMATIQUE
# ══════════════════════════════════════════════════════════════
_rollback() {
  if [ "$DEPLOY_SUCCESS" != "true" ] && [ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ]; then
    echo ""
    warning "Déploiement échoué — rollback en cours…"
    sudo rm -rf "$WEB_DIR" 2>/dev/null || true
    sudo mv "$BACKUP_PATH" "$WEB_DIR"
    success "Rollback effectué depuis $BACKUP_PATH"
  fi
}
trap '_rollback' EXIT

# ══════════════════════════════════════════════════════════════
#  UTILITAIRE : chercher un binaire dans PATH + /usr/sbin + /usr/local/sbin
# ══════════════════════════════════════════════════════════════
_find_bin() {
  command -v "$1" 2>/dev/null \
    || [ -x "/usr/sbin/$1"       ] && echo "/usr/sbin/$1"       \
    || [ -x "/usr/local/sbin/$1" ] && echo "/usr/local/sbin/$1" \
    || return 1
}

_has() { _find_bin "$1" &>/dev/null; }

# ══════════════════════════════════════════════════════════════
#  BANNER
# ══════════════════════════════════════════════════════════════
clear
echo -e "${PURPLE}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║        🚀  DEPLOYER PRO  v3.1                ║"
echo "  ║   static │ vue │ node │ laravel │ docker      ║"
echo "  ║   Nginx · PM2 · Docker · SSL · Rollback       ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 1 — Vérification des dépendances de base
# ══════════════════════════════════════════════════════════════
step 1 "Vérification des dépendances système"

MISSING=()
for bin in nginx git certbot curl; do
  if _has "$bin"; then
    BIN_PATH=$(_find_bin "$bin")
    success "$bin  ($BIN_PATH)"
  else
    warning "$bin manquant"
    MISSING+=("$bin")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  error "Paquets manquants : ${MISSING[*]}\nInstallez : sudo apt install ${MISSING[*]}"
fi
success "Toutes les dépendances de base sont présentes"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 2 — Collecte des informations & type de projet
# ══════════════════════════════════════════════════════════════
step 2 "Informations & type de projet"

read -rp "  Nom du projet       : " nameproject
read -rp "  Domaine (ex: a.com) : " fulldomain
read -rp "  URL du dépôt GitHub : " REPO_URL

# ── Détection automatique via l'API GitHub
REPO_PATH="${REPO_URL#*github.com/}"; REPO_PATH="${REPO_PATH%.git}"
info "Analyse du dépôt GitHub…"
API=$(curl -sf "https://api.github.com/repos/$REPO_PATH/contents" 2>/dev/null || echo "")

if   echo "$API" | grep -qE '"Dockerfile"|"docker-compose'; then AUTO_TYPE="docker"
elif echo "$API" | grep -q '"composer.json"';               then AUTO_TYPE="laravel"
elif echo "$API" | grep -q '"vite.config';                  then AUTO_TYPE="vue"
elif echo "$API" | grep -q '"package.json"';                then AUTO_TYPE="node"
else AUTO_TYPE="static"
fi

echo ""
echo -e "  ${BOLD}Type détecté : ${CYAN}$AUTO_TYPE${RESET}"
echo ""
echo -e "  ${BOLD}Choisissez le type de projet :${RESET}"
echo -e "  ${DIM}[1] static  — HTML/CSS/JS pur (aucun serveur)${RESET}"
echo -e "  ${DIM}[2] vue     — SPA Vue/React (build → dist/ statique)${RESET}"
echo -e "  ${DIM}[3] node    — API Node.js (PM2 + Nginx reverse proxy)${RESET}"
echo -e "  ${DIM}[4] laravel — PHP Laravel (php-fpm, pas de PM2)${RESET}"
echo -e "  ${DIM}[5] docker  — Container Docker (PM2 + Nginx reverse proxy)${RESET}"
echo ""

declare -A TYPE_MAP=([1]=static [2]=vue [3]=node [4]=laravel [5]=docker)
DEFAULT_NUM=1
for k in "${!TYPE_MAP[@]}"; do
  [ "${TYPE_MAP[$k]}" = "$AUTO_TYPE" ] && DEFAULT_NUM=$k
done

read -rp "  Votre choix [$DEFAULT_NUM] : " type_choice
type_choice="${type_choice:-$DEFAULT_NUM}"
PROJECT_TYPE="${TYPE_MAP[$type_choice]:-$AUTO_TYPE}"

# ── Port (node/docker uniquement)
if [ "$PROJECT_TYPE" = "node" ] || [ "$PROJECT_TYPE" = "docker" ]; then
  read -rp "  Port de l'app [3001]    : " input_port
  APP_PORT="${input_port:-3001}"
fi

# ── Validation des dépendances spécifiques au type
case $PROJECT_TYPE in
  laravel)
    _has php      || error "PHP non installé (requis pour Laravel)"
    _has composer || error "Composer non installé"
    ;;
  node|vue)
    _has node || error "Node.js non installé"
    _has npm  || error "npm non installé"
    ;;
  docker)
    if ! _has docker; then
      warning "Docker non installé — installation automatique…"
      spinner "Installation de Docker" bash -c 'curl -fsSL https://get.docker.com | sh'
      sudo usermod -aG docker "$USER"
      info "Docker installé — reconnexion SSH recommandée pour les permissions groupe"
    fi
    ;;
esac

echo ""
echo -e "  ${BOLD}Récapitulatif${RESET}"
echo -e "  🏷️  Projet  : ${CYAN}$nameproject${RESET}"
echo -e "  🌐 Domaine  : ${CYAN}$fulldomain${RESET}"
echo -e "  📦 Type     : ${GREEN}${BOLD}$PROJECT_TYPE${RESET}"
[ "$PROJECT_TYPE" = "node" ] || [ "$PROJECT_TYPE" = "docker" ] && \
  echo -e "  🔌 Port     : ${CYAN}$APP_PORT${RESET}"
echo ""
read -rp "  Confirmer et continuer ? [O/n] : " confirm
[[ "${confirm,,}" == "n" ]] && exit 0

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 3 — Backup de l'existant
# ══════════════════════════════════════════════════════════════
step 3 "Backup de l'existant"

WEB_DIR="/var/www/html/$fulldomain"

if [ -d "$WEB_DIR" ]; then
  BACKUP_PATH="/var/backups/${fulldomain}_$(date +%Y%m%d_%H%M%S)"
  sudo mkdir -p /var/backups
  spinner "Sauvegarde → $BACKUP_PATH" sudo cp -r "$WEB_DIR" "$BACKUP_PATH"
  info "Rollback automatique disponible si une étape échoue"
else
  skip "Aucun site existant à sauvegarder"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 4 — Base de données
# ══════════════════════════════════════════════════════════════
step 4 "Base de données"

case $PROJECT_TYPE in
  laravel)
    read -rsp "  Mot de passe MySQL pour '$nameproject' : " mysqlpassword; echo ""
    spinner "Création DB + user MySQL" sudo mysql -e \
      "CREATE DATABASE IF NOT EXISTS \`$nameproject\`;
       CREATE USER IF NOT EXISTS '$nameproject'@'localhost' IDENTIFIED BY '$mysqlpassword';
       GRANT ALL PRIVILEGES ON \`$nameproject\`.* TO '$nameproject'@'localhost';
       FLUSH PRIVILEGES;"
    ;;
  node|docker)
    if _has psql; then
      read -rsp "  Mot de passe PostgreSQL pour '$nameproject' : " pgpassword; echo ""
      spinner "Création DB + user PostgreSQL" sudo -u postgres psql -c \
        "DO \$\$ BEGIN
           IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$nameproject') THEN
             CREATE USER $nameproject WITH PASSWORD '$pgpassword';
           END IF;
         END \$\$;
         CREATE DATABASE $nameproject OWNER $nameproject;" 2>/dev/null || true
    else
      skip "PostgreSQL non installé — configurer la BDD manuellement"
    fi
    ;;
  *)
    skip "Aucune BDD requise pour le type '$PROJECT_TYPE'"
    ;;
esac

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 5 — Clonage
# ══════════════════════════════════════════════════════════════
step 5 "Clonage du dépôt"

[ -d "$WEB_DIR" ] && sudo rm -rf "$WEB_DIR"
sudo mkdir -p "$WEB_DIR"
sudo chown -R "$USER:$USER" "$WEB_DIR"
cd "$WEB_DIR"

spinner "git clone $REPO_URL" git clone "$REPO_URL" . || {
  warning "Clonage public échoué — dépôt privé ?"
  read -rsp "  Personal Access Token GitHub : " GH_PAT; echo ""
  REPO_URL_AUTH="${REPO_URL/https:\/\//https:\/\/$GH_PAT@}"
  spinner "git clone (authentifié)" git clone "$REPO_URL_AUTH" .
}

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 6 — Configuration du projet
# ══════════════════════════════════════════════════════════════
step 6 "Configuration du projet ($PROJECT_TYPE)"

case $PROJECT_TYPE in
  laravel)
    spinner "composer install" composer install --no-dev --optimize-autoloader
    cp .env.example .env
    php artisan key:generate
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=$nameproject/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=$nameproject/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$mysqlpassword/" .env
    WEB_ROOT="$WEB_DIR/public"
    ;;
  vue)
    spinner "npm ci"          npm ci
    spinner "npm run build"   npm run build
    if   [ -d "dist" ];  then WEB_ROOT="$WEB_DIR/dist"
    elif [ -d "build" ]; then WEB_ROOT="$WEB_DIR/build"
    else                      WEB_ROOT="$WEB_DIR"
    fi
    ;;
  node)
    spinner "npm ci" npm ci
    grep -q '"build"' package.json 2>/dev/null && \
      spinner "npm run build" npm run build || true
    WEB_ROOT="$WEB_DIR"
    ;;
  docker)
    WEB_ROOT="$WEB_DIR"
    skip "Pas de build local — Docker s'en charge à l'étape suivante"
    ;;
  *)
    WEB_ROOT="$WEB_DIR"
    success "Projet statique prêt"
    ;;
esac

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 7 — Docker
# ══════════════════════════════════════════════════════════════
step 7 "Docker"

if [ "$PROJECT_TYPE" = "docker" ]; then
  cd "$WEB_DIR"

  if [ -f "docker-compose.yml" ] || [ -f "compose.yml" ]; then
    info "docker-compose.yml détecté → Docker Compose"
    spinner "docker compose up -d --build" sudo docker compose up -d --build
    cat > "/home/$USER/start-$nameproject.sh" <<SH
#!/bin/bash
cd $WEB_DIR
sudo docker compose down 2>/dev/null || true
sudo docker compose up --build
SH
  else
    spinner "docker build -t $nameproject:latest" \
      sudo docker build -t "$nameproject:latest" "$WEB_DIR"
    cat > "/home/$USER/start-$nameproject.sh" <<SH
#!/bin/bash
sudo docker stop  $nameproject 2>/dev/null || true
sudo docker rm    $nameproject 2>/dev/null || true
sudo docker run --name $nameproject \
  --restart unless-stopped \
  -p ${APP_PORT}:${APP_PORT} \
  $nameproject:latest
SH
  fi
  chmod +x "/home/$USER/start-$nameproject.sh"
  success "Image Docker prête — script de démarrage créé"
else
  skip "Docker non requis pour le type '$PROJECT_TYPE'"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 8 — Configuration Nginx
# ══════════════════════════════════════════════════════════════
step 8 "Configuration Nginx"

NGINX_CONF="/etc/nginx/sites-available/$fulldomain.conf"

_sec_headers() {
  printf '    add_header X-Frame-Options         "SAMEORIGIN"   always;\n'
  printf '    add_header X-XSS-Protection        "1; mode=block" always;\n'
  printf '    add_header X-Content-Type-Options   "nosniff"      always;\n'
  printf '    add_header Referrer-Policy          "strict-origin-when-cross-origin" always;\n'
}

if [ "$PROJECT_TYPE" = "laravel" ]; then
  sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $fulldomain www.$fulldomain;
    root $WEB_ROOT;
    index index.php index.html;
    access_log /var/log/nginx/$fulldomain.access.log;
    error_log  /var/log/nginx/$fulldomain.error.log;
$(_sec_headers)
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffers 16 16k; fastcgi_buffer_size 32k;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2)$ {
        expires 1y; add_header Cache-Control "public, immutable";
    }

    location ~ /\.(?!well-known) { deny all; }
    location ~ /(\.env|composer\.(json|lock)|package\.(json|lock)) { deny all; }
}
EOF

elif [ "$PROJECT_TYPE" = "docker" ] || [ "$PROJECT_TYPE" = "node" ]; then
  sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $fulldomain www.$fulldomain;
    access_log /var/log/nginx/$fulldomain.access.log;
    error_log  /var/log/nginx/$fulldomain.error.log;
$(_sec_headers)
    location / {
        proxy_pass         http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection 'upgrade';
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location ~ /\.(?!well-known) { deny all; }
}
EOF

else
  # static / vue
  sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $fulldomain www.$fulldomain;
    root $WEB_ROOT;
    index index.html;
    access_log /var/log/nginx/$fulldomain.access.log;
    error_log  /var/log/nginx/$fulldomain.error.log;
$(_sec_headers)
    location / { try_files \$uri \$uri/ /index.html; }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        gzip_static on;
    }

    gzip on; gzip_vary on; gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml;

    location ~ /\.(?!well-known) { deny all; }
}
EOF
fi

success "Configuration Nginx générée"

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 9 — UFW
# ══════════════════════════════════════════════════════════════
step 9 "Pare-feu (UFW)"

if _has ufw && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
  sudo ufw allow 80/tcp  comment "HTTP"  &>/dev/null
  sudo ufw allow 443/tcp comment "HTTPS" &>/dev/null
  sudo ufw allow OpenSSH                  &>/dev/null
  sudo ufw reload &>/dev/null
  success "Ports 80, 443 et SSH autorisés dans UFW"
else
  skip "UFW inactif ou non installé"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 10 — Activation Nginx + test
# ══════════════════════════════════════════════════════════════
step 10 "Activation et test Nginx"

sudo ln -sf "$NGINX_CONF" "/etc/nginx/sites-enabled/$fulldomain.conf"

if sudo nginx -t 2>/dev/null; then
  sudo systemctl reload nginx
  success "Nginx rechargé sans erreur"
else
  sudo nginx -t
  error "Configuration Nginx invalide — voir l'erreur ci-dessus"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 11 — PM2 (node & docker uniquement)
# ══════════════════════════════════════════════════════════════
step 11 "Gestionnaire de processus PM2"

if [ "$PROJECT_TYPE" = "node" ] || [ "$PROJECT_TYPE" = "docker" ]; then
  if ! _has pm2; then
    spinner "npm install -g pm2" sudo npm install -g pm2
  fi

  ECO="/home/$USER/ecosystem.$nameproject.config.cjs"

  if [ "$PROJECT_TYPE" = "docker" ]; then
    cat > "$ECO" <<JS
module.exports = {
  apps: [{
    name: "$nameproject",
    script: "/home/$USER/start-$nameproject.sh",
    interpreter: "bash",
    watch: false,
    autorestart: true,
    restart_delay: 3000,
    max_restarts: 10,
    env: { NODE_ENV: "production" }
  }]
};
JS
  else
    MAIN_FILE="src/index.js"
    [ -f "$WEB_DIR/dist/index.js" ] && MAIN_FILE="dist/index.js"
    [ -f "$WEB_DIR/index.js"      ] && MAIN_FILE="index.js"
    cat > "$ECO" <<JS
module.exports = {
  apps: [{
    name: "$nameproject",
    script: "$WEB_DIR/$MAIN_FILE",
    cwd: "$WEB_DIR",
    instances: 1,
    exec_mode: "fork",
    watch: false,
    autorestart: true,
    restart_delay: 3000,
    max_restarts: 10,
    env: { NODE_ENV: "production", PORT: "$APP_PORT" }
  }]
};
JS
  fi

  pm2 delete "$nameproject" 2>/dev/null || true
  pm2 start "$ECO"
  pm2 save
  pm2 startup 2>/dev/null | grep -E "^sudo" | bash 2>/dev/null || true
  success "PM2 démarré — utilisez 'pm2 monit' pour le dashboard"
else
  skip "PM2 non requis pour le type '$PROJECT_TYPE'"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 12 — SSL (Let's Encrypt)
# ══════════════════════════════════════════════════════════════
step 12 "Certificat SSL (Let's Encrypt)"

if sudo certbot --nginx \
    -d "$fulldomain" -d "www.$fulldomain" \
    --non-interactive --agree-tos \
    --email "admin@$fulldomain" 2>/dev/null; then
  success "Certificat SSL installé (apex + www)"
else
  warning "Échec SSL — le domaine pointe-t-il vers ce serveur ?"
  info    "Réessayez : sudo certbot --nginx -d $fulldomain -d www.$fulldomain"
fi

# ══════════════════════════════════════════════════════════════
#  ÉTAPE 13 — Permissions + Health check
# ══════════════════════════════════════════════════════════════
step 13 "Permissions & Health check"

# Permissions
sudo chown -R www-data:www-data "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"
if [ "$PROJECT_TYPE" = "laravel" ]; then
  sudo chmod -R 775 "$WEB_DIR/storage" "$WEB_DIR/bootstrap/cache"
  cd "$WEB_DIR"
  sudo -u www-data php artisan config:cache
  sudo -u www-data php artisan route:cache
  sudo -u www-data php artisan view:cache
  info "N'oubliez pas : php artisan migrate"
fi
success "Permissions configurées"

# Health check
sleep 2
HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "https://$fulldomain" 2>/dev/null \
  || curl -sk -o /dev/null -w "%{http_code}" "http://$fulldomain" 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" =~ ^(200|301|302)$ ]]; then
  success "Health check OK — HTTP $HTTP_CODE"
else
  warning "Health check : HTTP $HTTP_CODE — vérifiez manuellement"
fi

# ── Désactiver le rollback (succès)
DEPLOY_SUCCESS=true

if [ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ]; then
  read -rp "  Supprimer le backup ($BACKUP_PATH) ? [o/N] : " del_bkp
  [[ "${del_bkp,,}" == "o" ]] && sudo rm -rf "$BACKUP_PATH" && info "Backup supprimé"
fi

# ══════════════════════════════════════════════════════════════
#  RÉSUMÉ FINAL
# ══════════════════════════════════════════════════════════════
TOTAL_TIME=$(_elapsed_total)
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║         ✅  DÉPLOIEMENT RÉUSSI  🎉           ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  🌐 URL           : ${CYAN}https://$fulldomain${RESET}"
echo -e "  📦 Type          : ${BOLD}$PROJECT_TYPE${RESET}"
echo -e "  📂 Racine web    : $WEB_ROOT"
echo -e "  🔁 Health check  : HTTP ${BOLD}$HTTP_CODE${RESET}"
echo -e "  ⏱  Durée totale  : ${BOLD}$TOTAL_TIME${RESET}"
echo ""

case $PROJECT_TYPE in
  node|docker)
    echo -e "  ${BOLD}Commandes PM2 :${RESET}"
    echo -e "  ${DIM}pm2 monit${RESET}               → Dashboard temps réel"
    echo -e "  ${DIM}pm2 logs $nameproject${RESET}   → Logs en direct"
    echo -e "  ${DIM}pm2 restart $nameproject${RESET} → Redémarrer"
    echo "" ;;
  laravel)
    echo -e "  ${YELLOW}⚠  N'oubliez pas :${RESET} php artisan migrate"
    echo "" ;;
esac

echo -e "  ${YELLOW}📋 Conseils :${RESET}"
echo    "  • Vérifiez le renouvellement SSL : sudo certbot renew --dry-run"
echo    "  • Configurez des sauvegardes automatiques (cron)"
[ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ] && \
  echo  "  • Backup conservé dans : $BACKUP_PATH"
echo ""
