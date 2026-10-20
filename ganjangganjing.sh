#!/bin/bash
# ============================================
#   👑 RENDZZ ULTIMATE PANEL v6.0
#   ALL-IN-ONE INSTALLER (UI + DB + Features)
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

[[ $EUID -ne 0 ]] && { echo -e "${RED}❌ Harus root!${NC}"; exit 1; }

clear
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  👑 RENDZZ ULTIMATE PANEL INSTALLER        ║${NC}"
echo -e "${CYAN}║  All Features in 1 Script                  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

PTERO_DIR="/var/www/pterodactyl"
TARGET_FILE="$PTERO_DIR/resources/views/templates/base/core.blade.php"
ADMIN_BLADE="$PTERO_DIR/resources/views/layouts/admin.blade.php"
WALLPAPER_DIR="$PTERO_DIR/public/rendzz"

# Cek folder
if [ ! -d "$PTERO_DIR" ]; then
    echo -e "${RED}❌ Folder Pterodactyl tidak ditemukan di $PTERO_DIR!${NC}"
    exit 1
fi

# ============ INPUT USER ============
echo -e "${YELLOW}📸 Masukkan URL Wallpaper (enter=skip):${NC}"
read -p "➤ " WALLPAPER_URL

echo ""

# ============ 1. SETUP DATABASE (USER EXPIRED) ============
echo -e "${CYAN}[1/4] Setup Database (Kolom User Expired)...${NC}"
DB_NAME=$(grep "DB_DATABASE" "$PTERO_DIR/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_USER=$(grep "DB_USERNAME" "$PTERO_DIR/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_PASS=$(grep "DB_PASSWORD" "$PTERO_DIR/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)

# Query tambah kolom expired_at
if mysql -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null; then
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW COLUMNS FROM users LIKE 'expired_at';" 2>/dev/null | grep -q expired_at || \
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "ALTER TABLE users ADD COLUMN expired_at DATETIME DEFAULT NULL;"
    echo -e "${GREEN}  ✓ Kolom 'expired_at' siap${NC}"
else
    echo -e "${YELLOW}  ⚠️ Gagal konek DB manual. (Bisa diabaikan)${NC}"
fi

# ============ 2. BIKIN FILE ASSETS (CSS & JS) ============
echo -e "${CYAN}[2/4] Bikin Asset (CSS, JS, Wallpaper)...${NC}"
mkdir -p "$WALLPAPER_DIR"

# Download Wallpaper
if [ -n "$WALLPAPER_URL" ]; then
    echo -e "  Mengunduh wallpaper..."
    curl -sL "$WALLPAPER_URL" -o "$WALLPAPER_DIR/bg.jpg"
    if [ -s "$WALLPAPER_DIR/bg.jpg" ]; then
        chmod 644 "$WALLPAPER_DIR/bg.jpg"
        echo -e "${GREEN}  ✓ Wallpaper OK${NC}"
    else
        echo -e "${RED}  ❌ Gagal download wallpaper, lanjut tanpa bg${NC}"
        rm -f "$WALLPAPER_DIR/bg.jpg"
    fi
fi

# CSS & JS untuk Admin Panel (Deep Purple)
cat > "$WALLPAPER_DIR/admin.css" << 'CSSEOF'
@import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css');
#app .bg-neutral-900 { background-color: #0d0617 !important; }
#app .navigation-link { border-radius: 8px !important; margin: 2px 10px !important; transition: all 0.2s ease !important; }
#app .navigation-link:hover { background-color: rgba(168, 85, 247, 0.15) !important; color: #d8b4fe !important; }
#app .navigation-link.active { background-color: rgba(168, 85, 247, 0.25) !important; border-left: 4px solid #a855f7 !important; color: #ffffff !important; }
#app .bg-neutral-800 { background: rgba(20, 10, 35, 0.8) !important; border: 1px solid rgba(168, 85, 247, 0.2) !important; }
#app h1, #app .text-2xl { text-shadow: 0 0 15px rgba(168, 85, 247, 0.6) !important; }
.navigation-link[href="/admin/servers"] .icon svg { display: none; }
.navigation-link[href="/admin/servers"] .icon::before { content: "\f233"; font-family: "Font Awesome 6 Free"; font-weight: 900; color: #38bdf8; }
.navigation-link[href="/admin/users"] .icon svg { display: none; }
.navigation-link[href="/admin/users"] .icon::before { content: "\f0c0"; font-family: "Font Awesome 6 Free"; font-weight: 900; color: #34d399; }
CSSEOF

# JS Injector Menu Expired
cat > "$WALLPAPER_DIR/admin.js" << 'JSEOF'
setTimeout(function() {
    const usersMenu = document.querySelector('a[href="/admin/users"]');
    if (!usersMenu || document.getElementById('menu-expired')) return;
    const newMenu = document.createElement('a');
    newMenu.id = 'menu-expired';
    newMenu.href = '/admin/users'; 
    newMenu.className = usersMenu.className;
    newMenu.innerHTML = `<div class="icon"><i class="fas fa-crown"></i></div><span>User Expired</span>`;
    newMenu.querySelector('i').style.color = '#fbbf24';
    usersMenu.parentNode.insertBefore(newMenu, usersMenu.nextSibling);
}, 2000);
JSEOF

echo -e "${GREEN}  ✓ Asset Admin OK${NC}"

# ============ 3. INJECT KE CORE BLADE (LOADER & UI USER) ============
echo -e "${CYAN}[3/4] Inject Tampilan Depan (Console Loader)...${NC}"

cat > "$TARGET_FILE" << 'BLADE_EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
    <div id="rendzz-loader">
        <div class="console-box">
            <div class="console-header">
                <span class="dot red"></span>
                <span class="dot yellow"></span>
                <span class="dot green"></span>
                <span class="console-title">rendzz@system: ~</span>
            </div>
            <div class="console-body" id="console-log"></div>
            <div class="console-cursor">_</div>
        </div>
    </div>

    <div id="modal-portal"></div>
    <div id="app"></div>

    <style>
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); }
        ::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #4ecdc4, #ff6b6b); border-radius: 10px; }

        #rendzz-loader {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            z-index: 999999; display: flex; align-items: center; justify-content: center;
            background: #0d1117; transition: opacity 0.6s ease, visibility 0.6s ease;
        }
        #rendzz-loader.hide-loader { opacity: 0; visibility: hidden; }
        
        .console-box {
            width: 90%; max-width: 600px; background: #161b22;
            border-radius: 10px; box-shadow: 0 20px 50px rgba(0,0,0,0.8), 0 0 0 1px #30363d;
            overflow: hidden; font-family: 'Courier New', monospace;
            transform: translateY(20px); animation: slideUp 0.5s ease-out forwards;
        }
        @keyframes slideUp { to { transform: translateY(0); } }
        
        .console-header { background: #0d1117; padding: 10px 15px; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #30363d; }
        .dot { width: 12px; height: 12px; border-radius: 50%; }
        .dot.red { background: #ff5f56; }
        .dot.yellow { background: #ffbd2e; }
        .dot.green { background: #27c93f; }
        .console-title { color: #8b949e; font-size: 13px; margin-left: 10px; font-weight: bold; }
        
        .console-body { padding: 20px; color: #c9d1d9; font-size: 14px; line-height: 1.6; min-height: 250px; max-height: 400px; overflow-y: auto; }
        .console-body .line { margin-bottom: 6px; display: flex; flex-wrap: wrap; }
        .console-body .time { color: #8b949e; margin-right: 10px; }
        .console-body .tag-info { color: #58a6ff; font-weight: bold; }
        .console-body .tag-ok { color: #3fb950; font-weight: bold; }
        .console-body .tag-warn { color: #d29922; font-weight: bold; }
        .console-body .tag-sec { color: #f85149; font-weight: bold; }
        .console-body .tag-done { color: #a371f7; font-weight: bold; }
        .console-body .text { color: #c9d1d9; margin-left: 5px; }
        
        .console-cursor { padding: 0 20px 20px; color: #3fb950; font-size: 14px; animation: blink 1s step-end infinite; font-weight: bold; }
        @keyframes blink { 50% { opacity: 0; } }

        body { background: url('/rendzz/bg.jpg') no-repeat center center fixed !important; background-size: cover !important; }
        body::after { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.45); pointer-events: none; z-index: 1; }
        #app, .content-wrapper { position: relative; z-index: 2; }

        .rendzz-particle { position: fixed; pointer-events: none; width: 6px; height: 6px; border-radius: 50%; background: #58a6ff; z-index: 99999; animation: fadeOutParticle 1s linear forwards; }
        @keyframes fadeOutParticle { 0% { opacity: 1; transform: scale(1); } 100% { opacity: 0; transform: scale(0); } }
    </style>

    <script>
        // CONSOLE LOADER
        document.addEventListener('DOMContentLoaded', function() {
            const logContainer = document.getElementById('console-log');
            const loader = document.getElementById('rendzz-loader');

            const logs = [
                { t: '00.00', tag: 'INFO', text: 'Initializing Rendzz Core System...' },
                { t: '00.01', tag: 'OK', text: 'Kernel modules loaded.' },
                { t: '00.05', tag: 'INFO', text: 'Connecting to database server...' },
                { t: '00.08', tag: 'OK', text: 'Database connection established.' },
                { t: '00.12', tag: 'SEC', text: 'Verifying access token & firewall...' },
                { t: '00.15', tag: 'WARN', text: 'Bypassing security protocols...' },
                { t: '00.20', tag: 'OK', text: 'Firewall bypassed successfully.' },
                { t: '00.25', tag: 'INFO', text: 'Loading React components & UI...' },
                { t: '00.30', tag: 'INFO', text: 'Applying Rendzz Unique Theme...' },
                { t: '00.35', tag: 'DONE', text: 'System ready. Welcome to Rendzz Panel!' }
            ];

            let currentLine = 0;

            function printLog() {
                if (currentLine < logs.length) {
                    const data = logs[currentLine];
                    let tagClass = 'tag-info';
                    if (data.tag === 'OK') tagClass = 'tag-ok';
                    if (data.tag === 'WARN') tag===Class = 'tag-warn';
                     if (data.tag === 'SEC') tag4Class = 'tag-se.c';
                    if (data.tag === ' INDONE') tagClassJECT = 'tag-done';

                    const line = document.createElement('div');
                    line.className = 'line';
                    line.innerHTML = `<span class="time">[${data.t}]</span><span class="${tagClass}">[${data.tag}]</span><span class="text">&nbsp;${data.text}</span>`;
                    
                    const textSpan = line.querySelector('.text');
                    const originalText = data.text;
                    textSpan.textContent = '';
                    
                    logContainer.appendChild(line);
                    logContainer.scrollTop = logContainer.scrollHeight;

                    let charIndex = 0;
                    const typing = setInterval(() => {
                        if (charIndex < originalText.length) {
                            textSpan.textContent += originalText.charAt(charIndex);
                            charIndex++;
                            logContainer.scrollTop = logContainer.scrollHeight;
                        } else {
                            clearInterval(typing);
                            currentLine++;
                            setTimeout(printLog, Math.random() * 100 + 50);
                        }
                    }, 10);
                } else {
                    setTimeout(hideLoader, 1200);
                }
            }

            function hideLoader() {
                if (loader && !loader.classList.contains('hide-loader')) {
                    loader.classList.add('hide-loader');
                    setTimeout(() => { if (loader) loader.remove(); }, 700);
                }
            }
            setTimeout(printLog, 500);
            setTimeout(hideLoader, 15000);
        });

        // PARTICLE CURSOR
        document.addEventListener('mousemove', function(e) {
            if (Math.random() > 0.3) return;
            var p = document.createElement('div');
            p.className = 'rendzz-particle';
            p.style.left = (e.pageX - 3) + 'px';
            p.style.top = (e.pageY - 3) + 'px';
            p.style.background = Math.random() > 0.5 ? '#58a6ff' : '#a371f7';
            document.body.appendChild(p);
            setTimeout(function() { p.remove(); }, 1000);
        });
    </script>
@endsection
BLADE_EOF

echo -e "${GREEN}  ✓ Core Loader OK${NC}"

# ========= KE ADMIN BLADE (CSS & JS) ============
echo -e "${CYAN}[4/4] Inject Tampilan Admin...${NC}"

# Pastikan admin.blade.php ada
if [ -f "$ADMIN_BLADE" ]; then
    cp "$ADMIN_BLADE" "$ADMIN_BLADE.bak"
    
    # Hapus inject lama (biar gak dobel)
    sed -i '/admin.css/d' "$ADMIN_BLADE"
    sed -i '/admin.js/d' "$ADMIN_BLADE"
    
    # Inject CSS & JS
    sed -i "s|</head>|<link rel=\"stylesheet\" href=\"/rendzz/admin.css?v=$(date +%s)\">\n</head>|" "$ADMIN_BLADE"
    sed -i "s|</body>|<script src=\"/rendzz/admin.js?v=$(date +%s)\"></script>\n</body>|" "$ADMIN_BLADE"
    
    echo -e "${GREEN}  ✓ Admin Theme OK${NC}"
else
    echo -e "${RED}  ❌ admin.blade.php tidak ditemukan!${NC}"
fi

# ============ CLEAR CACHE & PERMISSION ============
cd "$PTERO_DIR" 2>/dev/null
php artisan view:clear >/dev/null 2>&1
php artisan cache:clear >/dev/null 2>&1
php artisan route:clear >/dev/null 2>&1
php artisan config:clear >/dev/null 2>&1

chown -R www-data:www-data "$PTERO_DIR/public/rendzz"
chown -R www-data:www-data "$PTERO_DIR/resources/views"
chown -R www-data:www-data "$PTERO_DIR/storage"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ SEMUA FITUR BERHASIL DI-INSTALL!       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}🚀 Silakan buka Panel dan tekan CTRL+SHIFT+R (Hard Refresh)${NC}"
echo ""
