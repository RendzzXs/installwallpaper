#!/bin/bash

# -------------------------------
# RENDZZ UNIQUE EDITION v2.0
# + CUSTOM LOADING PAGE, PARTICLE CURSOR, SCROLLBAR
# -------------------------------
PTERO_DIR="/var/www/pterodactyl"
TARGET_FILE="$PTERO_DIR/resources/views/templates/base/core.blade.php"
FOOTER_FILE="$PTERO_DIR/resources/views/templates/base/footer.blade.php"
BACKUP_FILE="$PTERO_DIR/core.backup"
WALLPAPER_DIR="$PTERO_DIR/public/rendzz"
WALLPAPER_FILE="$WALLPAPER_DIR/bg.jpg"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'

show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}          🔥 RENDZZ UNIQUE EDITION v2.0 🔥          ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}        ! + Particle Cursor + Custom Scrollbar !     ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

uninstall_wallpaper() {
    show_header
    echo -e "${YELLOW}🗑️  Menghapus custom design...${NC}\n"
    
    if [ -d "$WALLPAPER_DIR" ]; then
        rm -rf "$WALLPAPER_DIR"
        echo -e "${GREEN}✅ Folder wallpaper dihapus${NC}"
    fi
    
    cat > "$TARGET_FILE" << 'EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
    <div id="modal-portal"></div>
    <div id="app"></div>
@endsection
EOF

    if [ -f "$FOOTER_FILE" ]; then
        sed -i 's/Rendzz Official®/Pterodactyl®/g' "$FOOTER_FILE"
        sed -i 's/© 2025 - 2026/© 2015 - 2026/g' "$FOOTER_FILE"
    fi
    
    cd "$PTERO_DIR" 2>/dev/null
    php artisan view:clear
    php artisan cache:clear
    
    echo -e "\n${GREEN}✅ Panel kembali normal!${NC}"
}

install_wallpaper() {
    show_header
    
    echo -e "${YELLOW}📸 Masukkan URL wallpaper:${NC}"
    echo -n "➤ "
    read WALLPAPER_URL
    
    if [ -z "$WALLPAPER_URL" ]; then
        echo -e "\n${RED}❌ URL tidak boleh kosong!${NC}"
        return 1
    fi
    
    cp "$TARGET_FILE" "$BACKUP_FILE" 2>/dev/null
    
    echo -e "\n${YELLOW}📥 Downloading wallpaper...${NC}"
    mkdir -p "$WALLPAPER_DIR"
    curl -L "$WALLPAPER_URL" -o "$WALLPAPER_FILE" --progress-bar
    
    if [ ! -f "$WALLPAPER_FILE" ]; then
        echo -e "\n${RED}❌ Gagal download wallpaper!${NC}"
        return 1
    fi
    
    chmod 644 "$WALLPAPER_FILE"
    chown -R www-data:www-data "$WALLPAPER_DIR" 2>/dev/null || chown -R nginx:nginx "$WALLPAPER_DIR" 2>/dev/null
    
    echo -e "${GREEN}✅ Wallpaper tersimpan${NC}\n"
    
    # FOOTER
    echo -e "${YELLOW}©️  Mengganti copyright footer...${NC}"
    cp "$FOOTER_FILE" "$FOOTER_FILE.bak" 2>/dev/null
    sed -i 's/Pterodactyl®/Rendzz Official®/g' "$FOOTER_FILE"
    sed -i 's/Pterodactyl/Rendzz Official/g' "$FOOTER_FILE"
    sed -i 's/© 2015 - 2026/© 2025 - 2026/g' "$FOOTER_FILE"
    sed -i 's/© [0-9]\{4\} - [0-9]\{4\}/© 2025 - 2026/g' "$FOOTER_FILE"
    echo -e "${GREEN}✅ Footer OK${NC}\n"
    
    # INJECT CORE BLADE
    echo -e "${YELLOW}🎨 Menginjeksi unique design...${NC}"
    
    cat > "$TARGET_FILE" << 'EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
    <div id="rendzz-loader">
        <div class="loader-bg"></div>
        <div class="loader-content">
            <div class="loader-spinner">
                <div class="spinner-ring"></div>
                <div class="spinner-ring"></div>
                <div class="spinner-ring"></div>
                <div class="spinner-core"></div>
            </div>
            <div class="loader-logo">RENDZZ</div>
            <div class="loader-text">
                <span class="dot-anim"></span>
                Memverifikasi Internet Anda
                <span class="dot-anim"></span>
            </div>
            <div class="loader-bar">
                <div class="loader-bar-fill"></div>
            </div>
            <div class="loader-sub">Mohon tunggu sebentar...</div>
        </div>
    </div>

    <div id="modal-portal"></div>
    <div id="app"></div>

    <style>
        /* ======================================= */
        /*   RENDZZ UNIQUE EDITION v2.0           */
        /* ======================================= */

        /* SCROLLBAR CUSTOM */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); }
        ::-webkit-scrollbar-thumb { 
            background: linear-gradient(180deg, #4ecdc4, #ff6b6b); 
            border-radius: 10px; 
        }
        ::-webkit-scrollbar-thumb:hover { background: #ff6b6b; }

        /* LOADING PAGE */
        #rendzz-loader {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            z-index: 999999; display: flex; align-items: center; justify-content: center;
            transition: opacity 0.6s ease, visibility 0.6s ease; overflow: hidden;
        }
        #rendzz-loader.hide-loader { opacity: 0; visibility: hidden; }
        
        .loader-bg {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: radial-gradient(circle at 30% 30%, #1a202c 0%, #0d1117 60%, #000000 100%);
            background-size: 200% 200%; animation: bgShift 8s ease infinite;
        }
        @keyframes bgShift { 0% {background-position: 0% 0%;} 50% {background-position: 100% 100%;} 100% {background-position: 0% 0%;} }
        
        .loader-bg::before, .loader-bg::after {
            content: ""; position: absolute; width: 3px; height: 3px;
            background: #4ecdc4; border-radius: 50%;
            box-shadow: 20vw 30vh 0 #4ecdc4, 40vw 70vh 0 #ff6b6b, 60vw 20vh 0 #4ecdc4, 80vw 80vh 0 #ff6b6b;
            animation: twinkle 3s ease-in-out infinite alternate;
        }
        @keyframes twinkle { 0% {opacity: 0.2;} 100% {opacity: 1;} }

        .loader-content { position: relative; z-index: 2; text-align: center; animation: fadeInLoader 0.8s ease-out; }
        @keyframes fadeInLoader { from {opacity: 0; transform: translateY(20px);} to {opacity: 1; transform: translateY(0);} }

        .loader-spinner { position: relative; width: 120px; height: 120px; margin: 0 auto 30px; }
        .spinner-ring { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border-radius: 50%; border: 3px solid transparent; }
        .spinner-ring:nth-child(1) { border-top-color: #4ecdc4; animation: spin 1.4s linear infinite; }
        .spinner-ring:nth-child(2) { border-right-color: #ff6b6b; animation: spin 1.8s linear infinite reverse; width: 80%; height: 80%; top: 10%; left: 10%; }
        .spinner-ring:nth-child(3) { border-bottom-color: #feca57; animation: spin 2.2s linear infinite; width: 60%; height: 60%; top: 20%; left: 20%; }
        .spinner-core { position: absolute; top: 50%; left: 50%; width: 24px; height: 24px; margin: -12px 0 0 -12px; background: linear-gradient(145deg, #4ecdc4, #ff6b6b); border-radius: 50%; box-shadow: 0 0 20px rgba(78, 205, 196, 0.8); animation: pulse 1.2s ease-in-out infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.3); } }

        .loader-logo { font-size: 42px; font-weight: 900; letter-spacing: 14px; color: #ffffff; text-shadow: 0 0 10px #4ecdc4, 0 0 20px #ff6b6b; margin-bottom: 25px; animation: logoGlow 2s ease-in-out infinite alternate; }
        @keyframes logoGlow { from { text-shadow: 0 0 10px #4ecdc4, 0 0 20px #4ecdc4; } to { text-shadow: 0 0 20px #ff6b6b, 0 0 40px #ff6b6b; } }

        .loader-text { font-size: 16px; color: #cbd5e0; letter-spacing: 2px; margin-bottom: 20px; font-weight: 500; display: flex; align-items: center; justify-content: center; gap: 8px; }
        .dot-anim { display: inline-block; width: 8px; height: 8px; background: #4ecdc4; border-radius: 50%; animation: dotBlink 1s ease-in-out infinite; }
        .dot-anim:last-child { background: #ff6b6b; animation-delay: 0.5s; }
        @keyframes dotBlink { 0%, 100% { opacity: 0.3; } 50% { opacity: 1; } }

        .loader-bar { width: 280px; height: 6px; background: rgba(255, 255, 255, 0.1); border-radius: 50px; margin: 0 auto 15px; overflow: hidden; }
        .loader-bar-fill { height: 100%; width: 0%; background: linear-gradient(90deg, #4ecdc4, #ff6b6b, #feca57); background-size: 200% 100%; border-radius: 50px; animation: progressFill 2.5s ease-in-out infinite, barGradient 2s linear infinite; }
        @keyframes progressFill { 0% { width: 0%; } 50% { width: 100%; } 100% { width: 0%; } }
        @keyframes barGradient { 0% { background-position: 0% 0%; } 100% { background-position: 200% 0%; } }

        .loader-sub { font-size: 12px; color: #718096; letter-spacing: 3px; text-transform: uppercase; }

        /* BACKGROUND */
        body { background: url('/rendzz/bg.jpg') no-repeat center center fixed !important; background-size: cover !important; }
        body::after { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.4); pointer-events: none; z-index: 1; }
        #app, .content-wrapper { position: relative; z-index: 2; }

        /* CARD */
        @keyframes slideInLeft { 0% { opacity: 0; transform: translateX(-50px); } 100% { opacity: 1; transform: translateX(0); } }
        .card { 
            background: rgba(255, 255, 255, 0.95) !important; 
            border: none !important; 
            border-radius: 20px 8px 20px 8px !important; 
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15) !important; 
            transition: all 0.3s ease !important; 
            animation: slideInLeft 0.6s ease-out !important; 
            position: relative; overflow: hidden; 
        }
        .card::before { content: ""; position: absolute; top: 0; left: 0; width: 5px; height: 100%; background: linear-gradient(180deg, #ff6b6b, #4ecdc4); }
        .card:hover { transform: translateY(-8px) scale(1.02); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25) !important; background: #fff !important; }
        .card-title { font-weight: 700 !important; color: #2d3748 !important; border-bottom: 2px dashed #4ecdc4; padding-bottom: 10px; margin-bottom: 15px; }

        /* DARK MODE */
        .dark-mode .card { background: rgba(26, 32, 44, 0.95) !important; color: white !important; }
        .dark-mode .card-title { color: white !important; }
        
        /* BUTTON */
        .btn { border-radius: 50px !important; padding: 8px 20px !important; font-weight: 600 !important; transition: all 0.2s ease !important; }
        .btn-primary { background: linear-gradient(145deg, #4ecdc4, #556270) !important; border: none !important; box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3) !important; }
        .btn-primary:hover { transform: scale(1.05); box-shadow: 0 6px 20px rgba(78, 205, 196, 0.4) !important; }

        /* PARTICLES CURSOR */
        .rendzz-particle { 
            position: fixed; pointer-events: none; width: 6px; height: 6px; 
            border-radius: 50%; background: #4ecdc4; z-index: 99999; 
            animation: fadeOutParticle 1s linear forwards;
        }
        @keyframes fadeOutParticle {
            0% { opacity: 1; transform: scale(1); }
            100% { opacity: 0; transform: scale(0); }
        }

        /* TOAST NOTIF */
        .rendzz-toast {
            position: fixed; bottom: 30px; right: 30px; background: rgba(26, 32, 44, 0.95);
            color: white; padding: 15px 25px; border-radius: 12px; border-left: 5px solid #4ecdc4;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5); z-index: 999999; font-weight: 600;
            transform: translateX(150%); transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .rendzz-toast.show { transform: translateX(0); }
        .rendzz-toast.error { border-left-color: #ff6b6b; }

        /* RESPONSIVE */
        @media (max-width: 600px) {
            .loader-logo { font-size: 28px; letter-spacing: 8px; }
            .loader-bar { width: 220px; }
            .loader-spinner { width: 90px; height: 90px; }
        }
    </style>

    <script>
        // HIDE LOADER
        (function() {
            var loader = document.getElementById('rendzz-loader');
            function hideLoader() {
                if (loader && !loader.classList.contains('hide-loader')) {
                    loader.classList.add('hide-loader');
                    setTimeout(function() { if (loader) loader.remove(); }, 700);
                }
            }
            var startTime = Date.now();
            function tryHide() {
                if (Date.now() - startTime < 2500) { setTimeout(tryHide, 100); return; }
                hideLoader();
            }
            function checkAppReady() {
                var app = document.getElementById('app');
                if (app && app.children.length > 0) tryHide();
                else setTimeout(checkAppReady, 200);
            }
            setTimeout(checkAppReady, 300);
            setTimeout(hideLoader, 8000);
        })();

        // PARTICLES CURSOR
        document.addEventListener('mousemove', function(e) {
            if (Math.random() > 0.3) return; // Batasi jumlah partikel
            var p = document.createElement('div');
            p.className = 'rendzz-particle';
            p.style.left = (e.pageX - 3) + 'px';
            p.style.top = (e.pageY - 3) + 'px';
            p.style.background = Math.random() > 0.5 ? '#4ecdc4' : '#ff6b6b';
            document.body.appendChild(p);
            setTimeout(function() { p.remove(); }, 1000);
        });
    </script>
@endsection
EOF

    sed -i 's/<title>.*<\/title>/<title>🔥 Rendzz Unique Edition 🔥<\/title>/g' "$PTERO_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null
    sed -i 's/<title>.*<\/title>/<title>🔥 Rendzz Unique Edition 🔥<\/title>/g' "$PTERO_DIR/resources/views/layouts/auth.blade.php" 2>/dev/null
    
    cd "$PTERO_DIR" 2>/dev/null
    php artisan view:clear
    php artisan cache:clear
    php artisan config:clear
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      ✅ INSTALLASI UNIQUE v2.0 BERHASIL! ✅            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🖼️  Wallpaper   : ${NC}CUSTOM"
    echo -e "${PURPLE}🃏 Server Card  : ${NC}Hexagon style & Hover naik"
    echo -e "${BLUE}✨ Particle     : ${NC}Efek bintang saat kursor digerakkan"
    echo -e "${YELLOW}🎨 Scrollbar    : ${NC}Custom gradient (Cyan/Pink)"
    echo -e "${GREEN}©️  Footer       : ${NC}Rendzz Official® © 2025-2026"
    echo -e "${MAGENTA}⏳ Loading Page : ${NC}Memverifikasi Internet Anda"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🚀 Refresh browser (CTRL+SHIFT+R)!${NC}"
}

while true; do
    show_header
    echo -e "${WHITE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║           🔥 PILIH MENU 🔥               ║${NC}"
    echo -e "${WHITE}╠════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║  ${RED}[1]${NC} 🗑️  HAPUS - Balik Normal         ${WHITE}║${NC}"
    echo -e "${WHITE}║  ${GREEN}[2]${NC} ✨ INSTALL - Unique Edition v2  ${WHITE}║${NC}"
    echo -e "${WHITE}║  ${BLUE}[x]${NC} ❌ KELUAR                       ${WHITE}║${NC}"
    echo -e "${WHITE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "${YELLOW}➤ Pilih menu [1/2/x]: ${NC}"
    read MENU
    
    case $MENU in
        1)
            uninstall_wallpaper
            echo ""; echo -ne "${CYAN}Tekan Enter...${NC}"; read
            ;;
        2)
            install_wallpaper
            echo ""; echo -ne "${CYAN}Tekan Enter...${NC}"; read
            ;;
        x)
            echo -e "\n${GREEN}✨ Thanks for using Rendzz Unique Edition!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1
            ;;
    esac
done
