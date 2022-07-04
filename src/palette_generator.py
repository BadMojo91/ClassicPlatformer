from PIL import Image

array = bytearray()
colors = 0

with open("palette.txt") as palette:
	for color in palette:
		data = bytearray.fromhex(color[1:7])
		array += data
		colors += 1

		print(colors, ': ' + str(color[1:7] + '\n')

img = Image.frombytes('RGB', (colors,1), bytes(array))
img.save('palette.png')
