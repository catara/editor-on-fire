#ifndef EOF_MENU_NATIVE_H
#define EOF_MENU_NATIVE_H

#include <allegro.h>

// [BEGIN gemini&catara | 2026-11-22 14:04 CET] Increase native menu capacity for rc16 + Rocksmith Focus submenus
#define EOF_MAX_NATIVE_MENUS 1024
#define EOF_MAX_MENU_ITEMS  8192
// [END gemini&catara | 2026-11-22 14:04 CET]

bool eof_set_up_native_menus(MENU * mp);
void eof_update_native_menus(void);
void eof_handle_native_menu_clicks(void);

#endif
