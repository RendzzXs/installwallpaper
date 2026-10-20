#!/bin/bash
# ============================================
#   👑 RENDZZ EXCLUSIVE ADMIN PANEL
#   New Menu • Elegant UI • Custom React
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

[[ $EUID -ne 0 ]] && { echo -e "${RED}❌ Harus root!${NC}"; exit 1; }

clear
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  👑 RENDZZ EXCLUSIVE ADMIN PANEL           ║${NC}"
echo -e "${CYAN}║  New Menu • Elegant UI • Custom React      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

PTERO_DIR="/var/www/pterodactyl"
ADMIN_CSS="$PTERO_DIR/public/rendzz/admin-exclusive.css"
ADMIN_JS="$PTERO_DIR/public/rendzz/admin-exclusive.js"

if [ ! -d "$PTERO_DIR" ]; then
    echo -e "${RED}❌ Folder Pterodactyl tidak ditemukan!${NC}"
    exit 1
fi

mkdir -p "$PTERO_DIR/public/rendzz"

# ============ 1. BIKIN CSS ADMIN BARU ============
echo -e "${CYAN}[1/3] Bikin CSS Admin Elegan...${NC}"

cat > "$ADMIN_CSS" << 'CSSEOF'
/* ========================================== */
/* RENDZZ EXCLUSIVE ADMIN CSS                 */
/* ========================================== */

@import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css');

/* Sidebar Deep Purple */
#app .bg-neutral-900 {
    background-color: #0f071a !important; /* Warna ungu gelap */
}

/* Menu Hover & Active */
#app .navigation-link {
    border-radius: 8px !important;
    margin: 2px 10px !important;
    transition: all 0.2s ease !important;
}

#app .navigation-link:hover {
    background-color: rgba(168, 85, 247, 0.1) !important;
    color: #d8b4fe !important;
}

#app .navigation-link.active {
    background-color: rgba(168, 85, 247, 0.2) !important;
    border-left: 4px solid #a855f7 !important;
    color: #fff !important;
}

/* Ganti Icon jadi FontAwesome */
.navigation-link[href="/admin"] .icon svg { display: none; }
.navigation-link[href="/admin"] .icon::before { content: "\f0e4"; font-family: "Font Awesome 6 Free"; font-weight: 900; color: #a855f7; }

.navigation-link[href="/admin/servers"] .icon svg { display: none; }
.navigation-link[href="/admin/servers"] .icon::before { content: "\f233"; font-family: "Font Awesome 6 Free"; font-weight: 900; color: #38bdf8; }

.navigation-link[href="/admin/users"] .icon svg { display: none; }
.navigation-link[href="/admin/users"] .icon::before { content: "\f0c0"; font-family: "Font Awesome 6 Free"; font-weight: 900; color: #34d399; }

/* Kotak Server List */
#app .bg-neutral-800 {
    background: rgba(15, 7, 26, 0.6) !important;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(168, 85, 247, 0.2) !important;
    border-radius: 16px !important;
}

/* Header Admin */
#app h1 {
    font-family: 'Inter', sans-serif;
    letter-spacing: -1px;
    text-shadow: 0 0 20px rgba(168, 85, 247, 0.4);
}
CSSEOF

echo -e "${GREEN}  ✓ CSS Admin siap${NC}"

# ============ 2. BIKIN SCRIPT JS UNTUK MENU BARU ============
echo -e "${CYAN}[2/3] Bikin Script React (Inject Menu)...${NC}"

cat > "$ADMIN_JS" << 'JSEOF'
// ==========================================
// RENDZZ ADMIN INJECTOR
// ==========================================

document.addEventListener('DOMContentLoaded', function() {
    setTimeout(injectMenu, 1500); // Tunggu React selesai render
});

function injectMenu() {
    // Cari menu "Users" di sidebar
    const usersMenu = document.querySelector('a[href="/admin/users"]');
    if (!usersMenu) return;

    // Cek kalau menu udah pernah di-inject
    if (document.getElementById('rendzz-expired-menu')) return;

    // Bikin elemen menu baru
    const newMenu = document.createElement('a');
    newMenu.id = 'rendzz-expired-menu';
    newMenu.href = '/admin/rendzz-expired'; // URL tujuan
    newMenu.className = usersMenu.className; // Samain classnya biar rapi
    newMenu.style.marginTop = '5px';
    
    // Isi menu dengan icon & teks
    newMenu.innerHTML = `
        <div class="icon"><i class="fas fa-crown"></i></div>
        <span>User Expired</span>
    `;

    // Kasih style khusus biar ikonnya warna emas
    newMenu.querySelector('i').style.color = '#fbbf24';

    // Sisipkan setelah menu Users
    usersMenu.parentNode.insertBefore(newMenu, usersMenu.nextSibling);
    
    console.log('✅ Rendzz Menu Injected!');
}
JSEOF

echo -e "${GREEN}  ✓ JS Injector siap${NC}"

# ============ 3. SUNCIK KE MASTER BLADE ============
echo -e "${CYAN}[3/3] Injeksi ke Panel...${NC}"

# Cari file layout utama Pterodactyl (biasanya admin.blade.php atau master.blade.php)
TARGET_LAYOUT="$PTERO_DIR/resources/views/layouts/admin.blade.php"
if [ ! -f "$TARGET_LAYOUT" ]; then
    TARGET_LAYOUT="$PTERO_DIR/resources/views/layouts/master.blade.php"
fi

if [ -f "$TARGET_LAYOUT" ]; then
    # Inject CSS sebelum </head>
    if ! grep -q "admin-exclusive.css" "$TARGET_LAYOUT"; then
        sed -i "s|</head>|<link rel=\"stylesheet\" href=\"/rendzz/admin-exclusive.css\">\n</head>|" "$TARGET_LAYOUT"
    fi
    
    # Inject JS sebelum </body>
    if ! grep -q "admin-exclusive.js" "$TARGET_LAYOUT"; then
        sed -i "s|</body>|<script src=\"/rendzz/admin-exclusive.js\"></script>\n</body>|" "$TARGET_LAYOUT"
    fi
    echo -e "${GREEN}  ✓ Berhasil di-inject ke layout${NC}"
else
    echo -e "${RED}  ❌ File layout tidak ditemukan. CSS gak bakal ke-load.${NC}"
fi

# Bikin file "Halaman Palsu" buat menu expired biar gak 404
TARGET_ROUTE="$PTERO_DIR/routes/admin.php"
if ! grep -q "rendzz-expired" "$TARGET_ROUTE"; then
    # Inject route buat nampilin halaman kosong sementara
    sed -i "$ a\\
\\
Route::get('/rendzz-expired', function () {\\
    return view('admin.rendzz-expired');\\
});" "$TARGET_ROUTE"
    
    mkdir -p "$PTERO_DIR/resources/views/admin"
    cat > "$PTERO_DIR/resources/views/admin/rendzz-expired.blade.php" << 'BLADE'
@extends('layouts.admin')
@section('title', 'User Expired')
@section('content')
<div class="px-12 py-8 bg-neutral-900 h-full">
    <h1 class="text-3xl font-bold text-white mb-4"><i class="fas fa-crown text-yellow-500 mr-2"></i> User Expired</h1>
    <div class="bg-neutral-800 p-6 rounded-lg border border-neutral-700">
        <p class="text-neutral-400">Halaman ini sedang dalam pengembangan (WIP). <br> Segera hadir dengan fitur manajemen VIP & Expired!</p>
    </div>
</div>
@endsection
BLADE
    echo -e "${GREEN}  ✓ Halaman Route Expired dibuat${NC}"
fi

# Clear Cache
cd "$PTERO_DIR" 2>/dev/null
php artisan view:clear >/dev/null 2>&1
php artisan route:clear >/dev/null 2>&1
php artisan cache:clear >/dev/null 2>&1

chown -R www-data:www-data "$PTERO_DIR/public/rendzz"
chown -R www-data:www-data "$PTERO_DIR/resources"
chown -R www-data:www-data "$PTERO_DIR/routes"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ ADMIN PANEL EXCLUSIVE SIAP!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📌 Apa yang berubah:${NC}"
echo -e "  1. Sidebar warna Deep Purple (Ungu)"
echo -e "  2. Icon menu berubah jadi lebih tajam"
echo -e "  3. Ada menu baru 'User Expired' (Ikon Mahkota)"
echo -e "  4. Kotak server jadi lebih elegan (Blur effect)"
echo ""
echo -e "${GREEN}🚀 Silakan Refresh Admin Panel (CTRL+SHIFT+R)!${NC}"
