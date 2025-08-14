package main

import (
	"embed"
	"fmt"
	"math"
	"strings"

	rl "github.com/gen2brain/raylib-go/raylib"
)

//go:embed assets/*.ogg
var assets embed.FS

type Instrument struct {
	Name  string
	Muted bool
	Sound rl.Sound
}

func main() {
	rl.SetTraceLogLevel(rl.LogFatal)
	rl.SetConfigFlags(rl.FlagWindowResizable)
	rl.InitWindow(1080, 720, "")
	defer rl.CloseWindow()
	rl.SetTargetFPS(15)
	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	files, err := assets.ReadDir("assets")
	for err != nil {
		rl.TraceLog(rl.LogFatal, "Failed to read assets directory: %v", err)
		return
	}

	instruments := make([]*Instrument, 0, len(files))
	for _, file := range files {
		if !strings.HasSuffix(file.Name(), ".ogg") {
			continue
		}
		b, _ := assets.ReadFile("assets/" + file.Name())
		sound := rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".ogg", b, int32(len(b))))
		name := file.Name()[:len(file.Name())-4]                 // Remove .ogg extension
		name = strings.TrimPrefix(name, "ribbits_")              // Remove prefix if exists
		name = strings.Title(strings.ReplaceAll(name, "_", " ")) // Capitalize the first letter
		instruments = append(instruments, &Instrument{name, false, sound})
		defer rl.UnloadSound(sound)
	}

	speed := 1.0
	for !rl.WindowShouldClose() {
		for i, inst := range instruments {
			if rl.IsKeyPressed(int32(rl.KeyOne + i)) {
				inst.Muted = !inst.Muted
				rl.SetSoundVolume(inst.Sound, float32(b2i(!inst.Muted)))
			}
		}

		if rl.IsKeyPressed(rl.KeyDown) {
			speed -= 0.5
		}
		if rl.IsKeyPressed(rl.KeyUp) {
			speed += 0.5
		}

		pitch := math.Pow(2, speed-1)
		for _, inst := range instruments {
			rl.SetSoundPitch(inst.Sound, float32(pitch))
			if !rl.IsSoundPlaying(inst.Sound) {
				rl.PlaySound(inst.Sound)
			}
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.Black)

		rl.DrawText(fmt.Sprintf("Speed Units: %.1f", speed), 30, 30, 30, rl.Blue)
		rl.DrawText(fmt.Sprintf("Pitch Factor: %.2f", pitch), 30, 80, 30, rl.Blue)

		for i, inst := range instruments {
			color := rl.Green
			if inst.Muted {
				color = rl.Gray
			}
			rl.DrawText(fmt.Sprintf("%d. %s", i+1, inst.Name), 50,
				int32(130+i*50), 30, color)
		}

		rl.EndDrawing()
	}
}

func b2i(b bool) int8 {
	if b {
		return 1
	}
	return 0
}
