#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <matplotlibcpp.h> // Make sure you have matplotlib-cpp installed and configured correctly.

namespace plt = matplotlibcpp;

int main() {
    std::string filename;
    int dimen, population, max_iter;

    // Get the parameters from the user
    std::cout << "Enter dimension, population, and max iterations: ";
    std::cin >> dimen >> population >> max_iter;

    // Get the filename from the user
    std::cout << "Enter the filename to plot data from: ";
    std::cin >> filename;

    // Read the data from the file
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Unable to open file: " << filename << std::endl;
        return 1;
    }

    std::vector<int> generations;
    std::vector<double> values;
    std::string line;
    while (std::getline(file, line)) {
        std::istringstream iss(line);
        int generation;
        double value;
        if (!(iss >> generation >> value)) {
            break;
        }
        generations.push_back(generation);
        values.push_back(value);
    }
    file.close();

    // Plot the data
    plt::figure_size(1200, 780);
    plt::xlabel("Generations");
    plt::ylabel("Value");
    plt::title("Best Value Over Generations (Dimen: " + std::to_string(dimen) + ", Population: " + std::to_string(population) + ", Max Iter: " + std::to_string(max_iter) + ")");
    plt::plot(generations, values, "g-");
    plt::grid(true);

    // Save or show the plot
    std::string output_file;
    std::cout << "Enter output image filename (e.g., output.png): ";
    std::cin >> output_file;
    plt::save(output_file);
    std::cout << "Plot saved to " << output_file << std::endl;

    return 0;
}
