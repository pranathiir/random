import turtle
import math

def julia(z, c, n=20):
    if abs(z) > 10 ** 12:
        return float("nan")
    elif n > 0:
        return julia(z ** 2 + c, c, n - 1)
    else:
        return z ** 2 + c

# Screen size (in pixels)
screenx, screeny = 800, 600

# Complex plane limits
complexPlaneX, complexPlaneY = (-2.0, 2.0), (-2.0, 2.0)

# Discretization step
step = 2

# Turtle configuration
turtle.tracer(0, 0)
turtle.setup(screenx, screeny)

screen = turtle.Screen()
screen.bgcolor("black")
screen.title("Julia Fractal (discretization step = %d)" % (int(step)))
jTurtle = turtle.Turtle()
jTurtle.penup()
jTurtle.shape("square")

# px * pixelToX = x in complex plane coordinates
pixelToX, pixelToY = (complexPlaneX[1] - complexPlaneX[0]) / screenx, (complexPlaneY[1] - complexPlaneY[0]) / screeny

# Julia set constant (change as needed)
c = complex(-0.7, 0.27015)

# Plot
for px in range(-int(screenx/2), int(screenx/2), int(step)):
    for py in range(-int(screeny/2), int(screeny/2), int(step)):
        x, y = px * pixelToX, py * pixelToY
        m = julia(0, x + 1j * y + c)
        if not math.isnan(m.real):
            color = [abs(math.sin(m.imag)) for i in range(3)]
            jTurtle.color(color)
            jTurtle.dot(2.4, color)
            jTurtle.goto(px, py)
    turtle.update()

turtle.mainloop()