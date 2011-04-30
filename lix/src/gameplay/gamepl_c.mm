/*
 * gameplay/gamepl_c.cpp
 *
 * The gameplay's calc loops.
 *
 */

#include "gameplay.h"

#include "../api/manager.h"
#include "../other/user.h"

#ifdef ALLEGRO_MACOSX
#include "LixMacManager.h"
#include "LixMacMacros.h"
#endif

void Gameplay::calc()
{
    // Wenn nicht gestartet, macht dies nix
    Network::calc();

    if (window_gameplay) {
        calc_window();
        // This is a bit kludgy, but it prevents opening the window
        // immediately again during a network game on an ESC press
        if (window_gameplay && Network::get_started()
         && !window_gameplay->get_game_end()) calc_self();
    } else if (([[LixMacManager sharedManager] quitAlertOpen] || ![allegroWindow isKeyWindow]) && !Network::get_started()) { // TODO: Check to make sure that it doesn't pause in a network game
		// Do nothing
	}
    else calc_self();
}



void Gameplay::calc_window()
{
    mouse_cursor.set_x_frame(0);
    mouse_cursor.set_y_frame(0);

    Api::WindowGameplay::ExitWith exit_with = window_gameplay->get_exit_with();
    if (exit_with != Api::WindowGameplay::NOTHING) {
        switch (exit_with)
        {
        case Api::WindowGameplay::RESUME:
            // debugging: irgendwie werden sonst Panels geloescht
            pan.set_draw_required();
            break;

        case Api::WindowGameplay::MENU:
            save_result();
            exit = true;
            break;

        case Api::WindowGameplay::RESTART:
            save_result();
            load_state(state_manager.load_zero());
            pan.pause      .set_off();
            pan.speed_slow .set_off();
            pan.speed_fast .set_off();
            pan.speed_turbo.set_off();
            break;

        default:
            break;
        }
        delete window_gameplay;
        window_gameplay = 0;
    }
}



// ############################################################################
// ############################################################################
// ############################################################################



void Gameplay::calc_self()
{
    // Berechnungen, die in jedem Tick, nicht nur in jedem Update
    // ausgef�hrt werden m�ssen
    ++local_ticks;

    // Aendert die Mauskoordinaten ggf., also frueh aufrufen!
    map.calc_scrolling();

    mouse_cursor.set_x_frame(0);
    mouse_cursor.set_y_frame(0);

    if (malo && malo->aiming == 2) {
        mouse_cursor.set_x_frame(1);
        mouse_cursor.set_y_frame(2);
    }
    else if (map.get_scrollable()
     && (useR->scroll_right  && hardware.get_mrh()
      || useR->scroll_middle && hardware.get_mmh())) {
        mouse_cursor.set_x_frame(3);
    }



    // ec kurz fuer exit_count
    unsigned ec = effect.get_effects();
    for (Tribe::CIt t = cs.tribes.begin(); t != cs.tribes.end(); ++t)
     ec += t->lix_hatch + t->get_lix_out();
    for (IacIt i = cs.trap.begin(); i != cs.trap.end(); ++i)
     ec += i->get_x_frame();
    // Check also for !window_gameplay, as in a networked game,
    // the action keeps running in the background
    if (ec == 0 && !window_gameplay) {
        chat.set_type_off();
        if (cs.tribes.size() == 1) {
            // Ergebnisfenster anzeigen
            window_gameplay = new Api::WindowGameplay(&replay,
             trlo->lix_saved, level.required, level.initial, trlo->skills_used,
             // Augenzucker bei null Geretteten, wird ohnehin nicht gespeichert
             (trlo->lix_saved > 0 ? update_last_exiter : cs.update),
              level.get_name());
            Api::Manager::add_elder(window_gameplay);
        }
        else {
            window_gameplay = new Api::WindowGameplay(&replay, cs.tribes, trlo,
             cs.tribes.size(), level.get_name(), &level);
            Api::Manager::add_elder(window_gameplay);
        }
        return;
    }
    // Beachte das return im vorhergehenden if.

    pan.calc();
    chat.calc();

    // Konsole deaktiviert, normale Buttons ansehen und,
    // wenn kein Replay stattfindet, auch den aktiven Main-Loop abarbeiten
    // console_tt_on_last_frame is a bit kludgy, but it works nicely.
    // Gameplay is not an elder, so this will get calced every frame here,
    // and without said variable, the console would be opened again upon
    // sending text with enter or the menu would open on cancelling typing.
    if (!chat.get_type_on()) {
        // Speichern
        if (pan.get_mode_single() && pan.state_save.get_clicked()) {
            state_manager.save_user(cs);
        }

        // Laden
        if (pan.get_mode_single() && pan.state_load.get_clicked()) {
            load_state(state_manager.load_user());
        }

        // Pause
        if (pan.get_mode_single() && pan.pause.get_clicked() || [[LixMacManager sharedManager] quitAlertOpen]) {
            pan.pause.set_on(!pan.pause.get_on());
        }
        // Zoom
        if (pan.zoom.get_clicked()) {
            pan.zoom.set_on(!pan.zoom.get_on());
            map.set_zoom(pan.zoom.get_on());
        }
        // Geschwindigkeit
        if (pan.get_mode_single()) {
            GameplayPanel::BiB* b
             = pan.speed_slow .get_clicked() ? &pan.speed_slow
             : pan.speed_fast .get_clicked() ? &pan.speed_fast
             : pan.speed_turbo.get_clicked() ? &pan.speed_turbo : 0;
            if (b) {
                bool was_on = b->get_on();
                pan.speed_slow .set_off();
                pan.speed_fast .set_off();
                pan.speed_turbo.set_off();
                b->set_on(!was_on);
            }
        }
        // Neustart
        if (pan.get_mode_single() && pan.restart.get_clicked()) {
            load_state(state_manager.load_zero());
        }

        // Konsoleneingabe aktivieren
        if (!pan.get_mode_single()
         && !chat.get_type_on_last_frame()
         && hardware.key_once(useR->key_chat)) {
            chat.set_type_on();
        }

        // Beenden bzw. Menue?
        if (hardware.key_once(KEY_ESC)
         && !chat.get_type_on_last_frame()
         && !window_gameplay) {
            window_gameplay = new Api::WindowGameplay(&replay,
                               Network::get_started() ? &level : 0);
            Api::Manager::add_elder(window_gameplay);
            return;
        }
    }
    // Ende von deaktivierter Konsole





    // Replay oder normales Spiel: Hauptsaechlichkeiten abarbeiten
    // Wenn ein Geschwindigkeitsbutton angeklickt oder per Hotkey aktiviert
    // wurde, dann ueberspringen wir den Replay-Abbruch doch noch.
    if (replaying && (hardware.get_ml()
     || cs.update >= replay.get_max_updates()
     || replay.get_max_updates() == 0)) {
        bool b = true; // Replay abbrechen?
        if (hardware.get_ml() &&
           (pan.state_save .is_mouse_here()
         || pan.state_load .is_mouse_here()
         || pan.pause      .is_mouse_here()
         || pan.zoom       .is_mouse_here()
         || pan.speed_slow .is_mouse_here()
         || pan.speed_fast .is_mouse_here()
         || pan.speed_turbo.is_mouse_here()
         || pan.restart    .is_mouse_here())) b = false;
        if (b) {
            replaying = false;
            replay.erase_data_after_update(cs.update);
            pan.speed_fast .set_off();
            pan.speed_turbo.set_off();
        }
    }

    // Grafikeffekte muessen noch vor dem Update berechnet werden,
    // aber geschwindigkeitsmaessig unabhaengig von den cs.update
    // Trotzdem "cs.update" uebergeben, damit zu alte Effektspeicherungen
    // wieder geloescht werden koennen.
    effect.calc(cs.update);





    // Steuerung der Lemminge
    if (!replaying && !chat.get_type_on()) calc_active();

    // Jetzt die Schleife f�r ein Update, also eine Gameplay-Zeiteinheit
    // Dies prueft nicht die lokalen Ticks, sondern richtet sich nur nach
    // den vom Timer gezaehlten Ticks!
    if (pan.get_mode_single()) {
        if (!pan.pause.get_on()) {
            if (pan.speed_turbo.get_on()) {
                if (Help::timer_ticks >= timer_tick_last_update
                                       + timer_ticks_for_update_fast)
                 for (unsigned i = 0; i < turbo_times_faster_than_fast; ++i) {
                    update();
                }
            }
            else if (pan.speed_fast.get_on()) {
                if (Help::timer_ticks >= timer_tick_last_update
                                       + timer_ticks_for_update_fast) {
                    update();
                }
            }
            else if (pan.speed_slow.get_on()) {
                if (Help::timer_ticks >= timer_tick_last_update
                                       + timer_ticks_for_update_slow) {
                    update();
                }
            }
            else if (Help::timer_ticks >= timer_tick_last_update
                                        + timer_ticks_for_update_normal) {
                update();
            }
        }
    }
    // Im Netzwerk die Zeit anhand der Server-Informationen synchronisieren
    else {
        unsigned u = Network::get_updates();
        if (u != 0) {
            u += Network::get_ping_millis()
               * Help::timer_ticks_per_second / 1000 / 2 // /2: ping=Roundtrip
               / timer_ticks_for_update_normal;          // u = Ziel-Update
            unsigned t = timer_ticks_for_update_normal;
            if      (u > cs.update + 10) t -= 2;
            else if (u > cs.update     ) t -= 1;
            else if (u < cs.update - 10) t += 1;
            else if (u < cs.update     ) t += 2;
            timer_ticks_for_update_client = t;
        }
        // In jedem Fall das Update normal rechnen, wie oben ohne Netz
        if (Help::timer_ticks >= timer_tick_last_update
                               + timer_ticks_for_update_client) update();
    }

}
// Ende von main_loop_calc()



void Gameplay::load_state(const State& state)
{
    if (state) {
        cs = state;
        // Replay nicht laden, sondern das derzeitige ab dort abspielen
        replaying = cs.update < replay.get_max_updates();
        // Panel aktualisieren
        if (trlo) pan.set_like_tribe(trlo, malo);
        // Sauberputzen
        effect.delete_after(cs.update);
    }
}
