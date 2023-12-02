numbers = []

count = 0
with open("input.txt") as file:
    for line in file:
        numbers.append(int(line.replace("\n", "")))

for i in range(0, len(numbers) - 2):
    if i == 0: continue
    a = numbers[i - 1] + numbers[i] + numbers[i + 1]
    b = numbers[i] + numbers[i + 1] + numbers[i + 2]

    if a < b: count += 1

print(count)