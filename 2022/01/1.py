with open("input.txt") as file:
    last = -1
    count = 0
    for line in file:
        x = int(line.replace("\n", ""))
        if last != -1 and last < x:
                count += 1

        last = x

    print(count)