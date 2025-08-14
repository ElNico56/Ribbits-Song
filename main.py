import os
import raylibpy as rl


def format_display_name(filename):
    name = os.path.splitext(filename)[0]  # remove .ogg
    name = name.replace("ribbit_", "")
    name = name.replace("_", " ")  # underscores → spaces
    return name.title()  # capitalize words


def main():
    rl.set_trace_log_level(rl.LOG_ERROR)
    rl.set_config_flags(rl.FLAG_WINDOW_RESIZABLE)
    rl.init_window(1080, 720, "")
    rl.set_target_fps(15)
    rl.init_audio_device()

    files = [f for f in os.listdir("assets") if f.lower().endswith(".ogg")]
    if not files:
        print("No .ogg files found in current directory.")
        rl.close_audio_device()
        rl.close_window()
        return
    names = [format_display_name(f) for f in files]
    sounds = [rl.load_sound(os.path.join("assets", path)) for path in files]
    volumes = [1.0 for _ in files]
    speed = 1.0

    while not rl.window_should_close():

        for i in range(len(files)):
            if rl.is_key_pressed(rl.KEY_ONE + i):
                volumes[i] = 1 - volumes[i]
                rl.set_sound_volume(sounds[i], volumes[i])

        if rl.is_key_pressed(rl.KEY_DOWN):
            speed = speed - 0.5
        if rl.is_key_pressed(rl.KEY_UP):
            speed = speed + 0.5

        pitch = 2 ** (speed - 1)
        for s in sounds:
            rl.set_sound_pitch(s, pitch)

        if not any(rl.is_sound_playing(s) for s in sounds):
            for s in sounds:
                rl.play_sound(s)

        rl.begin_drawing()
        rl.clear_background(rl.BLACK)

        rl.draw_text(f"Speed Units: {speed:.1f}", 30, 30, 30, rl.BLUE)
        rl.draw_text(f"Pitch Factor: {pitch:.2f}", 30, 80, 30, rl.BLUE)

        for i, (name, volume) in enumerate(zip(names, volumes)):
            color = rl.GREEN if volume > 0 else rl.RED
            rl.draw_text(f"{i+1}. {name}", 50, 130 + i * 50, 30, color)

        rl.end_drawing()

    for s in sounds:
        rl.unload_sound(s)
    rl.close_audio_device()
    rl.close_window()


if __name__ == "__main__":
    main()
