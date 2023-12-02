x = y = 0

with open("input.txt") as file:
    for line in file:
        raw = line.replace("\n", "").split(" ")
        action = raw[0]
        value = int(raw[1])

        if action == "forward":
            x += value
        elif action == "up":
            y -= value
        elif action == "down":
            y += value
        else:
            print("ERROR")

print(f"{x} {y}")
print(x * y)