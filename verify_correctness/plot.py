import matplotlib.pyplot as plt

def plot_from_txt(filename, dimen, population, max_iter):
    generations = []
    values = []

    # Read data from txt file
    try:
        with open(filename, 'r') as file:
            for line in file:
                parts = line.split()
                if len(parts) == 2:
                    generations.append(int(parts[0]))
                    values.append(float(parts[1]))
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        return
    except ValueError:
        print("Error: Unable to parse the data from the file. Ensure it is formatted correctly.")
        return

    # Plot the data
    plt.figure(figsize=(12, 8))
    plt.plot(generations, values, label='Best value so far', color='g', linewidth=2)
    plt.xlabel('GENERATIONS', fontsize=15)
    plt.ylabel('VALUE', fontsize=15)
    plt.title(f'Best Value Over Generations (Dimen: {dimen}, Population: {population}, Max Iter: {max_iter})', fontsize=18)
    plt.grid(True)
    plt.legend()

    # Save and show the plot
    output_file = input("Enter output image filename (e.g., output.png): ")
    plt.savefig(output_file)
    print(f"Plot saved to {output_file}")
    plt.show()

if __name__ == "__main__":
    filename = input("Enter the filename to plot data from: ")
    dimen = int(input("Enter dimension: "))
    population = int(input("Enter population: "))
    max_iter = int(input("Enter max iterations: "))
    plot_from_txt(filename, dimen, population, max_iter)
