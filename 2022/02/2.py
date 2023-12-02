
THRESHOLD = 3
HERTZ = 30

def eval_saccades(x_data: list[int], y_data: list[int]):
    samples = eval_samples(False)
    dist_list = [((x_data[i] - x_data[i - 1]) ** 2 + (y_data[i] - y_data[i - 1]) ** 2 ) ** 0.5 for i in range(1, samples)]

    fixations = []
    current = 0.0

    for dist in dist_list:
        if dist < THRESHOLD:
            current += 1 / HERTZ
        elif current > 0:
            fixations.append(current)
            current = 0

    if current > 0:
        fixations.append(current)

    sum = 0
    for f in fixations:
        sum += f

    return sum / len(fixations)