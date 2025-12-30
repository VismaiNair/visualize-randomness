package main

import (
	"bytes"
	"encoding/base64"
	"math"
	"math/rand/v2"
	"syscall/js"

	"github.com/fogleman/gg"
)

type Point struct {
	X, Y float64
}

func takeStep(stepLength float64) Point {
	degree := float64(rand.IntN(361))
	radians := (degree * math.Pi) / 180

	newPoint := Point{
		X: (stepLength * math.Cos(radians)),
		Y: (stepLength * math.Sin(radians)),
	}

	return newPoint
}

// Modified to return image bytes instead of saving to file
func walk(stepLength float64, numSteps int, width int, height int) ([]byte, error) {
	ctx := gg.NewContext(width, height)

	ctx.SetRGB(1, 1, 1)
	ctx.Clear()

	currentPos := Point{X: float64(width / 2), Y: float64(height / 2)}

	ctx.SetRGB(0.259, 0.522, 0.957)
	ctx.DrawCircle(currentPos.X, currentPos.Y, 5)
	ctx.Fill()

	for i := 0; i < numSteps; i++ {
		step := takeStep(stepLength)
		oldPos := currentPos

		currentPos.X += step.X
		currentPos.Y += step.Y

		ctx.SetRGB(0.204, 0.659, 0.325)
		ctx.DrawLine(oldPos.X, oldPos.Y, currentPos.X, currentPos.Y)
		ctx.Stroke()
		ctx.DrawCircle(currentPos.X, currentPos.Y, 5)
		ctx.Fill()
	}

	// Encode to PNG in memory
	var buf bytes.Buffer
	err := ctx.EncodePNG(&buf)
	if err != nil {
		return nil, err
	}

	return buf.Bytes(), nil
}

// WASM wrapper function
func walkWrapper(this js.Value, args []js.Value) interface{} {
	if len(args) != 4 {
		return map[string]interface{}{
			"error": "Expected 4 arguments: stepLength, numSteps, width, height",
		}
	}

	stepLength := args[0].Float()
	numSteps := args[1].Int()
	width := args[2].Int()
	height := args[3].Int()

	imageBytes, err := walk(stepLength, numSteps, width, height)
	if err != nil {
		return map[string]interface{}{
			"error": err.Error(),
		}
	}

	// Return base64 encoded image
	base64Image := base64.StdEncoding.EncodeToString(imageBytes)

	return map[string]interface{}{
		"success": true,
		"image":   base64Image,
	}
}

func main() {
	// Register the function to be callable from JavaScript/WASM
	js.Global().Set("walk", js.FuncOf(walkWrapper))

	// Keep the program running
	select {}
}
