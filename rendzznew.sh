#!/bin/bash
# ============================================
#   🔥 RENDZZ ULTIMATE EDITION v3.0
#   Console Loader • Particle • Glassmorphism
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'

[[ $EUID -ne 0 ]] && { echo -e "${RED}❌ Harus root!${NC}"; exit 1; }

PTERO_DIR="/var/www/pterodactyl"
TARGET_FILE="$PTERO_DIR/resources/views/templates/base/core.blade.php"
FOOTER_FILE="$PTERO_DIR/resources/views/templates/base/footer.blade.php"
BACKUP_FILE="$PTERO_DIR/core.backup"
WALLPAPER_DIR="$PTERO_DIR/public/rendzz"
WALLPAPER_FILE="$WALLPAPER_DIR/bg.jpg"

show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}        🔥 RENDZZ ULTIMATE EDITION v3.0 🔥            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}   Console Loader • Particle • Glassmorphism          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

uninstall_all() {
    show_header
    echo -e "${YELLOW}🗑️  Menghapus custom design...${NC}\n"
    
    [ -d "$WALLPAPER_DIR" ] && rm -rf "$WALLPAPER_DIR" && echo -e "${GREEN}✅ Wallpaper dihapus${NC}"
    
    cat > "$TARGET_FILE" << 'EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])
@section('container')
    <div id="modal-portal"></div>
    <div id="app"></div>
@endsection
EOF

    [ -f "$FOOTER_FILE" ] && sed -i 's/Rendzz Official®/Pterodactyl®/g; s/© 2025 - 2026/© 2015 - 2026/g' "$FOOTER_FILE"
    
    cd "$PTERO_DIR" 2>/dev/null && php artisan view:clear >/dev/null 2>&1 && php artisan cache:clear >/dev/null 2>&1
    
    echo -e "\n${GREEN}✅ Panel kembali normal!${NC}"
}

install_all() {
    show_header
    
    echo -e "${YELLOW}📸 Masukkan URL Wallpaper (enter=skip):${NC}"
    echo -n "➤ "
    read WALLPAPER_URL
    
    [ -f "$TARGET_FILE" ] && cp "$TARGET_FILE" "$BACKUP_FILE"
    
    if [ -n "$WALLPAPER_URL" ]; then
        echo -e "\n${YELLOW}📥 Downloading wallpaper...${NC}"
        mkdir -p "$WALLPAPER_DIR"
        curl -sL "$WALLPAPER_URL" -o "$WALLPAPER_FILE"
        
        if [ -f "$WALLPAPER_FILE" ] && [ -s "$WALLPAPER_FILE" ]; then
            chmod 644 "$WALLPAPER_FILE"
            chown -R www-data:www-data "$WALLPAPER_DIR" 2>/dev/null
            echo -e "${GREEN}✅ Wallpaper tersimpan${NC}"
        else
            echo -e "${RED}❌ Gagal download, skip wallpaper${NC}"
            rm -f "$WALLPAPER_FILE"
        fi
    fi
    
    [ -f "$FOOTER_FILE" ] && sed -i 's/Pterodactyl®/Rendzz Official®/g; s/© [0-9]\{4\} - [0-9]\{4\}/© 2025 - 2026/g' "$FOOTER_FILE"
    
    echo -e "\n${YELLOW}🎨 Menginjeksi Ultimate Design...${NC}"
    
    cat > "$TARGET_FILE" << 'BLADE_EOF'
@extends('templates/wrapper', [
    'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
    {{-- ============ CONSOLE LOADER ============ --}}
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
        /* ============ SCROLLBAR ============ */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.2); }
        ::-webkit-scrollbar-thumb { background: linear-gradient(180deg, #4ecdc4, #ff6b6b); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #ff6b6b; }

        /* ============ CONSOLE LOADER ============ */
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
        .console-body .text { color: #c9d1d9; }
        
        .console-cursor { padding: 0 20px 20px; color: #3fb950; font-size: 14px; animation: blink 1s step-end infinite; font-weight: bold; }
        @keyframes blink { 50% { opacity: 0; } }

        /* ============ BODY BACKGROUND ============ */
        body { background: url('/rendzz/bg.jpg') no-repeat center center fixed !important; background-size: cover !important; }
        body::after { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.45); pointer-events: none; z-index: 1; }
        #app, .content-wrapper { position: relative; z-index: 2; }

        /* ============ CARD GLASSMORPHISM ============ */
        @keyframes slideInLeft { 0% { opacity: 0; transform: translateX(-50px); } 100% { opacity: 1; transform: translateX(0); } }
        .card { 
            background: rgba(255, 255, 255, 0.95) !important; border: none !important;
            border-radius: 20px 8px 20px 8px !important;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15) !important;
            transition: all 0.3s ease !important;
            animation: slideInLeft 0.6s ease-out !important;
            position: relative; overflow: hidden;
        }
        .card::before { content: ""; position: absolute; top: 0; left: 0; width: 5px; height: 100%; background: linear-gradient(180deg, #ff6b6b, #4ecdc4); }
        .card:hover { transform: translateY(-8px) scale(1.02); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25) !important; background: #fff !important; }
        .card-title { font-weight: 700 !important; color: #2d3748 !important; border-bottom: 2px dashed #4ecdc4; padding-bottom: 10px; margin-bottom: 15px; }

        /* ============ DARK MODE ============ */
        .dark-mode .card { background: rgba(26, 32, 44, 0.95) !important; color: white !important; }
        .dark-mode .card-title { color: white !important; }

        /* ============ BUTTON ============ */
        .btn { border-radius: 50px !important; padding: 8px 20px !important; font-weight: 600 !important; transition: all 0.2s ease !important; }
        .btn-primary { background: linear-gradient(145deg, #4ecdc4, #556270) !important; border: none !important; box-shadow: 0 4px 15px rgba(78, 205, 196, 0.3) !important; }
        .btn-primary:hover { transform: scale(1.05); box-shadow: 0 6px 20px rgba(78, 205, 196, 0.4) !important; }

        /* ============ PARTICLE CURSOR ============ */
        .rendzz-particle { position: fixed; pointer-events: none; width: 6px; height: 6px; border-radius: 50%; background: #58a6ff; z-index: 99999; animation: fadeOutParticle 1s linear forwards; }
        @keyframes fadeOutParticle { 0% { opacity: 1; transform: scale(1); } 100% { opacity: 0; transform: scale(0); } }

        /* ============ TOAST ============ */
        .rendzz-toast {
            position: fixed; bottom: 30px; right: 30px; background: rgba(26, 32, 44, 0.95);
            color: white; padding: 15px 25px; border-radius: 12px; border-left: 5px solid #4ecdc4;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5); z-index: 999999; font-weight: 600;
            transform: translateX(150%); transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .rendzz-toast.show { transform: translateX(0); }
        .rendzz-toast.error { border-left-color: #ff6b6b; }

        /* ============ RESPONSIVE ============ */
        @media (max-width: 600px) {
            .console-box { width: 95%; }
            .console-body { font-size: 12px; padding: 15px; min-height: 200px; }
            .console-title { font-size: 11px; }
        }
    </style>

    <script>
        // ============ CONSOLE LOADER LOGIC ============
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
                    if (data.tag === 'WARN') tagClass = 'tag-warn';
                    if (data.tag === 'SEC') tagClass = 'tag-sec';
                    if (data.tag === 'DONE') tagClass = 'tag-done';

                    const line = document.createElement('div');
                    line.className = 'line';
                    line.innerHTML = `
                        <span class="time">[${data.t}]</span>
                        <span class="${tagClass}">[${data.tag}]</span>
                        <span class="text">&nbsp;${data.text}</span>
                    `;
                    
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
                            setTimeout(printLog, Math.random() * 300 + 100);
                        }
                    }, 20);
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

        // ============ PARTICLE CURSOR ============
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
    
    sed -i 's/<title>.*<\/title>/<title>🔥 Rendzz Ultimate Edition 🔥<\/title>/g' "$PTERO_DIR/resources/views/layouts/admin.blade.php" 2>/dev/null
    sed -i 's/<title>.*<\/title>/<title>🔥 Rendzz Ultimate Edition 🔥<\/title>/g' "$PTERO_DIR/resources/views/layouts/auth.blade.php" 2>/dev/null
    
    cd "$PTERO_DIR" 2>/dev/null
    php artisan view:clear >/dev/null 2>&1
    php artisan cache:clear >/dev/null 2>&1
    php artisan config:clear >/dev/null 2>&1
    
    chown -R www-data:www-data "$PTERO_DIR/resources" 2>/dev/null
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      ✅ ULTIMATE EDITION v3.0 BERHASIL! ✅             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🖥️  Loader      : ${NC}Console Terminal Style"
    echo -e "${PURPLE}✨ Particle     : ${NC}Cursor effect (Blue/Purple)"
    echo -e "${BLUE}🎨 Scrollbar    : ${NC}Custom gradient (Cyan/Pink)"
    echo -e "${YELLOW}🃏 Card         : ${NC}Hexagon + Hover Animation"
    echo -e "${GREEN}©️  Footer       : ${NC}Rendzz Official® © 2025-2026"
    echo -e "${MAGENTA}🌙 Dark Mode    : ${NC}Auto Support"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🚀 Refresh browser (CTRL+SHIFT+R)!${NC}"
}

# ============ MAIN MENU ============
while true; do
    show_header
    echo -e "${WHITE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║           🔥 PILIH MENU 🔥               ║${NC}"
    echo -e "${WHITE}╠════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║  ${RED}[1]${NC} 🗑️  HAPUS - Balik Normal         ${WHITE}║${NC}"
    echo -e "${WHITE}║  ${GREEN}[2]${NC} 🔥 INSTALL - Ultimate v3.0      ${WHITE}║${NC}"
    echo -e "${WHITE}║  ${BLUE}[x]${NC} ❌ KELUAR                       ${WHITE}║${NC}"
    echo -e "${WHITE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "${YELLOW}➤ Pilih menu [1/2/x]: ${NC}"
    read MENU
    
    case $MENU in
        1) uninstall_all; echo ""; echo -ne "${CYAN}Enter...${NC}"; read ;;
        2) install_all; echo ""; echo -ne "${CYAN}Enter...${NC}"; read ;;
        x) echo -e "\n${GREEN}✨ Thanks for using Rendzz Ultimate!${NC}\n"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
    esac
done
