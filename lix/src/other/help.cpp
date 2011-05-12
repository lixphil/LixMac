/*
 * libhelp.cpp
 *
 */

#include "../other/myalleg.h"
#include <cmath>   // Hypot: Brauche std::sqrt
#include <iomanip> // Fuer stringstream
#include <string>
#include <sstream>
#include <vector>

#include "user.h"
#include "help.h"
#include "log.h"

#include "../graphic/glob_gfx.h" // color[COL_BLACK]

namespace Help {

// Timer-Funktionen
volatile Uint32 timer_ticks            =  0;
const    int    timer_ticks_per_second = 60;

void timer_increment_ticks() {
    ++timer_ticks;
}
END_OF_FUNCTION(increment_ticks)

void timer_start() {
    LOCK_VARIABLE (timer_ticks);
    LOCK_FUNCTION (timer_increment_ticks);
    install_int_ex(timer_increment_ticks,
     BPS_TO_TIMER (timer_ticks_per_second));
}

unsigned int get_timer_ticks_per_draw() {
    if (get_refresh_rate() != 0) {
        const unsigned i = timer_ticks_per_second / get_refresh_rate();
        if (i > 0) return i;
        else       return 1;
    }
    // Dies nimmt notfalls an, dass der Monitor 60 Hz hat bei 120 Ticks/Sek.
    else return gloB->screen_vsync + 1;
}
// Ende der Timer-Funktionen



double hypot(const int x1, const int y1,
             const int x2, const int y2)
{
    return std::sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
}

int mod(int base, int modulo)
{
    if  (modulo < 0) modulo *= -1;
    return (base % modulo + modulo) % modulo;
}

double random_double(const double min, const double max)
{
    // Umwandlung zu float reicht nicht, wenn wir durch (max - min) teilen,
    // ggf. ueberlaeuft dann der Double. Also lieber * 1.0 vorneweg.
    return (rand() * 1.0 / RAND_MAX) * (max - min) + min;
}



MainArgs parse_main_arguments(int argc, char *argv[])
{
    MainArgs main_args;
    main_args.scr_f = !useR->screen_windowed;
    main_args.scr_x = 0;
    main_args.scr_y = 0;
    main_args.sound_load_driver = gloB->sound_load_driver;

    // Argumente parsen:
    // Es kommt derzeit nur darauf an, ob in allen Argumenten ein bestimmter
    // Buchstabe ist oder nicht.
    for (int i = 1; i < argc; ++i)
     for (unsigned pos = 0; argv[i][pos] != '\0'; ++pos)
     switch (argv[i][pos]) {
    case 'w':
        main_args.scr_f = false;
        main_args.scr_x = LEMSCR_X;
        main_args.scr_y = LEMSCR_Y;
        break;

    case 'n':
        // Die globale Konfigdatei sowie die Userdatei des letzten Benutzers
        // wurden bereits geladen. Damit dennoch die Nachfrage zu Beginn
        // kommt, killen wir den User wieder.
        gloB->user_name = "";
        useR->load();
        break;

    case 'o':
        main_args.sound_load_driver = false;
        break;

    default:
        break;
    }
    return main_args;
}
// Ende von parse_main_arguments



std::string version_to_string(const unsigned long nr) {
    std::ostringstream sstr;
    sstr << nr;
    std::string s = sstr.str();
    if (s.size() < 10) return s;
    s.insert( 4, "-");
    s.insert( 7, "-");
    s.insert(10, "-");
    if (nr % 100 == 0) s.resize(s.size() - 3);
    return s;
}
void string_to_nice_case(std::string& s) {
    for (std::string::iterator i = ++s.begin(); i != s.end(); ++i) {
        if (*i >= 'A' && *i <= 'Z') *i = *i + 'a' - 'A';
    }
}



void string_remove_extension(std::string& s) {
    for (std::string::iterator i = --s.end(); i != --s.begin()
                                           && i !=   s.begin(); --i) {
        if (*i == '.') {
            s.erase(i, s.end());
            break;
        }
        else if (*i == '/') break;
}   }
void string_remove_dir(std::string& s) {
    std::string::iterator i = s.end();
    if (i != s.begin()) --i;
    if (i != s.begin() && *i == '/') --i; // Falls selbst ein Verzeichnis
    for (; i != --s.begin(); --i) {
        if (*i == '/') {
            s.erase(s.begin(), ++i);
            break;
}   }   }
void string_cut_to_dir(std::string& s) {
    for (std::string::iterator i = --s.end(); i != --s.begin(); --i) {
        if (*i == '/') {
            s.erase(++i, s.end());
            break;
}   }   }
void string_shorten(std::string& s, const FONT* ft, const int length) {
    if (text_length(ft, s.c_str()) > length) {
        while (text_length(ft, s.c_str()) > length - text_length(ft, "..."))
         s.resize(s.size() - 1);
        s += "...";
    }
}



char string_get_pre_extension(const std::string& s)
{
    // Schaue, ob das letzte Zeichen eines endungslosen Strings gesucht ist
    std::string::const_iterator itr = --s.end();
    if (*--itr == '.') return *++itr;

    // Sonst: Durchsuche einen String mit Endung nach der Prae-Endung
    else for (itr = --s.end(); itr != --s.begin(); --itr) {
        if (*itr == '.') {
            if (--itr == --s.begin()) return '\0';
            if (--itr == --s.begin()) return '\0';
            else if (*itr == '.')     return *++itr; // "bla.A.txt" -> 'A'
            else                      return '\0';   // "bla.txt"   -> '\0'
            break;
        }
    }
    return '\0'; // Falls nicht einmal '.' enthalten
}

std::string string_get_extension(const std::string& s)
{
    std::string ext = "";
    std::string::const_iterator itr = --s.end();
    while (itr != s.begin() && itr != --s.begin() && *itr != '.') --itr;
    while (itr != s.end()   && itr != --s.begin()) {
        ext += *itr;
        ++itr;
    }
    return ext;
}

bool string_ends_with(const std::string& s, const std::string& tail)
{
    return s.size() >= tail.size()
     && std::string(s.end() - tail.size(), s.end()) == tail;
}





void draw_shaded_text(Torbit& bmp, FONT* f, const char* s,
 int x, int y, int r, int g, int b) {
    textout_ex(bmp.get_al_bitmap(), f, s, x+2, y+2, makecol(r/4, g/4, b/4),-1);
    textout_ex(bmp.get_al_bitmap(), f, s, x+1, y+1, makecol(r/2, g/2, b/2),-1);
    textout_ex(bmp.get_al_bitmap(), f, s, x  , y  , makecol(r  , g  , b  ),-1);
}
void draw_shadow_text(
 Torbit& bmp, FONT* f, const char* s, int x, int y, int c, int sc) {
    textout_ex(bmp.get_al_bitmap(), f, s, x+1, y+1, sc, -1);
    textout_ex(bmp.get_al_bitmap(), f, s, x  , y  , c,  -1);
}
void draw_shaded_centered_text(BITMAP *bmp, FONT* f, const char* s,
 int x, int y, int r, int g, int b) {
    textout_centre_ex(bmp, f, s, x+1, y+2, makecol(r/4, g/4, b/4), -1);
    textout_centre_ex(bmp, f, s, x  , y+1, makecol(r/2, g/2, b/2), -1);
    textout_centre_ex(bmp, f, s, x-1, y  , makecol(r  , g  , b  ), -1);
}
void draw_shadow_centered_text(
 Torbit& bmp, FONT* f, const char* s, int x, int y, int c, int sc) {
    textout_centre_ex(bmp.get_al_bitmap(), f, s, x+1, y+1, sc, -1);
    textout_centre_ex(bmp.get_al_bitmap(), f, s, x  , y  , c,  -1);
}
void draw_shadow_fixed_number(
 Torbit& bmp, FONT* f, int number, int x, int y,
 int c, bool right_to_left, int sc) {
    std::ostringstream s;
    s << number;
    draw_shadow_fixed_text(bmp,
     f, s.str(), x, y, c, right_to_left, sc);
}
void draw_shadow_fixed_text(
 Torbit& bmp, FONT* f, const std::string& s, int x, int y,
 int c, bool right_to_left, int sc) {
    char ch[2]; ch[1] = '\0';
    for (std::string::const_iterator i
     =  (right_to_left ? --s.end() : s.begin());
     i!=(right_to_left ? --s.begin() : s.end());
        (right_to_left ? --i : ++i))
    {
        if (right_to_left) x -= 10;
        ch[0] = *i;
        if (ch[0] >= '0' && ch[0] <= '9')
             Help::draw_shadow_text         (bmp, f, ch, x,     y, c, sc);
        else Help::draw_shadow_centered_text(bmp, f, ch, x + 5, y, c, sc);
        if (!right_to_left) x += 10;
    }
}
void draw_shadow_fixed_updates_used(
 Torbit& bmp, FONT* f, int number, int x, int y,
 int c, bool right_left, int sc) {
    // Minuten
    std::ostringstream s;
    s << number / (gloB->updates_per_second * 60);
    s << ':';
    // Sekunden
    if  ((number / gloB->updates_per_second) % 60 < 10) s << '0';
    s << (number / gloB->updates_per_second) % 60;
    // s += useR->language == Language::GERMAN ? ',' : '.';
    // Sekundenbruchteile mit zwei Stellen
    // ...schreiben wir nicht. Wird zu unuebersichtlich.
    // int frac = number % Gameplay::updates_per_second
    //            * 100  / Gameplay::updates_per_second;
    // if (frac < 10) s += '0';
    // s += frac;
    draw_shadow_fixed_text(bmp, f, s.str(), x, y, c, right_left, sc);
}
// Ende der Schattentexte









// Dateisuchfunktionen in verschiedenen Variationen
void find_files(
    const std::string& where,
    const std::string& what,
    DoStr              dostr,
    void*              from
) {
    al_ffblk info;
    std::string search_for = where + what;
    if (al_findfirst(search_for.c_str(), &info,
     FA_RDONLY | FA_HIDDEN | FA_LABEL | FA_ARCH) == 0) {
        do {
            // Gefundene Datei zum Vektor hinzuf�gen
            std::string s = where + info.name;
            dostr(s, from);
        } while (al_findnext(&info) == 0);
        al_findclose(&info);
    }
}
// Ende der Dateisuche



void find_dirs(std::string where, DoStr dostr, void* from)
{
    al_ffblk info;
    if (where[where.size()-1] != '/') where += '/';
    if (where[where.size()-1] != '*') where += '*';
    if (al_findfirst(where.c_str(), &info,
     FA_RDONLY | FA_HIDDEN | FA_LABEL | FA_DIREC | FA_ARCH) == 0) {
        do {
            // Gefundenes Verzeichnis hinzuf�gen
            if ((info.attrib & FA_DIREC) == FA_DIREC && info.name[0] != '.') {
                std::string s = where;
                s.resize(s.size() -1 ); // * von der Maske abschnibbeln
                s += info.name;
				s += '/';
                dostr(s, from);
            }
        } while (al_findnext(&info) == 0);
        al_findclose(&info);
    }
}
// Ende der Pfadsuche



void find_tree
(std::string where, const std::string& what, DoStr dostr, void* from)
{
    // Nach Verzeichnissen suchen
    al_ffblk info;
    if (where[where.size()-1] != '/') where += '/';
    std::string search_for = where + '*';
    if (al_findfirst(search_for.c_str(), &info,
     FA_RDONLY | FA_HIDDEN | FA_LABEL | FA_DIREC | FA_ARCH) == 0) {
        do {
            // Dies nur f�r jedes Verzeichnis au�er . und .. ausf�hren:
            // Neue Suche mit gleichem Vektor im gefundenen Verzeichnis
            if ((info.attrib & FA_DIREC) == FA_DIREC && info.name[0] != '.') {
                find_tree(where + info.name + '/', what, dostr, from);
            }
        } while (al_findnext(&info) == 0);
        al_findclose(&info);
    }
    // Nach Dateien suchen, die dem Suchkriterium entsprechen
    find_files(where, what, dostr, from);
}
// Ende der Unterverzeichnis-einschlie�enden Dateisuche



bool dir_exists(const std::string& s)
{
    std::string dir = s;
    if (dir[dir.size() - 1] == '/') dir.erase(--dir.end());
    return file_exists(dir.c_str(), FA_DIREC, 0);
}

}
// Ende des Namensraumes
