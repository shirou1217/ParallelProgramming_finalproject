#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <random>
#include <limits>
#include <fstream>
#include <chrono>
#include <cuda_runtime.h>
// #include "/home/pp24/pp24s036/firefly/NVTX/c/include/nvtx3/nvtx3.hpp"


using namespace std;

// CUDA version of the fitness function (fun)

// double* arr[1024];
// 1 block, 1024 threads: 1024 elements
// warp_reduce: google
// 1 block, 32 ~ 128 threads: 1024 elements

// 1024 threads -> 32 warp -> CUDA -> 1 warp = 32 threads
// thread in a wrap can use register to swap data -> each wrap use wrap reduce -> each wrap has only 1 sum
// write 32 sum to shared memory
// let 1 wrap to read shared memory
// do wrap reduce, write back to the fitness
// swap data between wraps -> use shared memory

// N blocks, each block 1024 threads, block i deal with pop[i][0~D-1]


// [[...],
//  [...],
//  [...]]

// pop: N x D, fitness: N
__global__ static void fun_kernel(double* pop, double* fitness, int N, int D) {

    // Best practice: coalesced access
    // threads in wrap accesses continous memory
    // warp0 ( 0 ~ 31)
    // warp1 (32 ~ 63)

    // D = 1024
    // warp 0 ~ 32 -> 1024: 1024 x
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) {
    //     double funsum = 0.0;
    //     for (int j = 0; j < D; j++) {
    //         // thread 0: pop[0 ~ D]   0
    //         // thread 1: pop[D ~ 2D]  D
    //         double x = pop[idx * D + j];
    //         funsum += x * x - 10 * cos(2 * M_PI * x);
    //     }
    //     funsum += 10 * D;
    //     fitness[idx] = funsum;
        double funsum = 0.0;
        //printf("Thread info - idx: %d, blockIdx.x: %d, blockDim.x: %d, threadIdx.x: %d\n",idx, blockIdx.x, blockDim.x, threadIdx.x);
        printf("Thread info: idx = %d\n", idx);
        if (idx < 10) {
            printf("Thread info - idx: %d, blockIdx.x: %d, blockDim.x: %d, threadIdx.x: %d\n", idx, blockIdx.x, blockDim.x, threadIdx.x);
        }

            // Coalesced access: Each thread processes a column of `pop`
            for (int j = threadIdx.x; j < D; j += blockDim.x) {
                double x = pop[idx + j * N];  // Coalesced memory access
                funsum += x * x - 10 * cosf(2 * M_PI * x);
            }

            // Aggregate the result
            fitness[idx] = funsum + 10 * D;
    }
}

class FA {
public:
    FA(int dimen, int population, int max_iter)
        : D(dimen), N(population), it(max_iter), A(0.97), B(1.0), G(0.0001) {
        Ub.resize(D, 3.0);
        Lb.resize(D, 0.0);
    }

    vector<double> fun(const vector<double>& pop) {
        vector<double> fitness(N);

        // Allocate GPU memory
        double* d_pop;
        double* d_fitness;
        cudaMalloc(&d_pop, N * D * sizeof(double));
        cudaMalloc(&d_fitness, N * sizeof(double));

        // Copy data to GPU
        cudaMemcpy(d_pop, pop.data(),N * D * sizeof(double), cudaMemcpyHostToDevice);

        // Launch kernel
        int blockSize = 1024;
        int numBlocks = (N + blockSize - 1) / blockSize;

        // GPU A100 has 108SM, each SM can compute multi-block
        // 1 block -> SM
        std::cerr << "numBlocks: " << numBlocks << std::endl;
        fun_kernel<<<numBlocks, blockSize>>>(d_pop, d_fitness, N, D);
        cudaDeviceSynchronize();
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl;
        }
        // Copy results back to CPU
        cudaMemcpy(fitness.data(), d_fitness, N * sizeof(double), cudaMemcpyDeviceToHost);

        // Free GPU memory
        cudaFree(d_pop);
        cudaFree(d_fitness);
        cudaDeviceReset(); // Clean up and flush device logs

        return fitness;
    }

    int D;                  // Dimension of problems
    int N;                  // Population size
    int it;                 // Max iteration
    vector<double> Ub;      // Upper bound
    vector<double> Lb;      // Lower bound
    double A;               // Strength
    double B;               // Attractiveness constant
    double G;               // Absorption coefficient
};

int main() {
    int dimen, population, max_iter;

    auto start_time = chrono::high_resolution_clock::now();

    random_device rd;
    mt19937 gen(0); // rd()
    uniform_real_distribution<> dis(-1024, 1024);

    FA fa(1024, 5, 5);
    vector<double> pop(fa.N * fa.D); // 1D array for population
    
    // Initialize population
    for (int i = 0; i < fa.N; i++) {
        for (int j = 0; j < fa.D; j++) {
            pop[i * fa.D + j] = dis(gen); // Linear indexing
        }
    }

    vector<double> fitness = fa.fun(pop);

    vector<double> best_list;
    vector<vector<double>> best_para_list;

    auto min_iter = min_element(fitness.begin(), fitness.end());
    best_list.push_back(*min_iter);
    int arr = distance(fitness.begin(), min_iter);

    // Extract the best parameters
    vector<double> best_para(fa.D);
    for (int j = 0; j < fa.D; j++) {
        best_para[j] = pop[arr * fa.D + j];
    }
    best_para_list.push_back(best_para);

    double best_iter;
    double best_ = numeric_limits<double>::max();
    vector<double> best_para_(fa.D);

    int it = 1;
    while (it < fa.it) {
        for (int i = 0; i < fa.N; i++) {
            for (int j = 0; j < fa.D; j++) {
                double steps = fa.A * (dis(gen) - 0.5) * abs(fa.Ub[0] - fa.Lb[0]);
                double r_distance = 0;

                for (int k = 0; k < fa.N; k++) {
                    if (fitness[i] > fitness[k]) {
                        r_distance += pow(pop[i * fa.D + j] - pop[k * fa.D + j], 2);
                        double Beta = fa.B * exp(-fa.G * r_distance);
                        double xnew = pop[i * fa.D + j] + Beta * (pop[k * fa.D + j] - pop[i * fa.D + j]) + steps;

                        xnew = min(max(xnew, fa.Lb[0]), fa.Ub[0]);
                        pop[i * fa.D + j] = xnew;

                        // Update fitness after position update
                        fitness = fa.fun(pop);
                        auto best_iter = min_element(fitness.begin(), fitness.end());
                        best_ = *best_iter;
                        int arr_ = distance(fitness.begin(), best_iter);

                        for (int j = 0; j < fa.D; j++) {
                            best_para_[j] = pop[arr_ * fa.D + j];
                        }
                    }
                }
            }
        }
        best_list.push_back(best_);
        best_para_list.push_back(best_para_);
        it++;
        cout << "Iteration " << it << " finished" << endl;
    }

    // Save results to file
    ofstream file("results_cuda.csv");
    if (file.is_open()) {
        // Write header
        file << "Dimension_1";
        for (int d = 1; d < fa.D; ++d) {
            file << ",Dimension_" << d + 1;
        }
        file << ",Fitness\n";

        // Write population matrix and fitness
        for (int i = 0; i < fa.N; ++i) {
            for (int j = 0; j < fa.D; ++j) {
                file << pop[i * fa.D + j];
                if (j < fa.D - 1) {
                    file << ",";
                }
            }
            file << "," << fitness[i] << "\n";
        }

        // Write best fitness values
        file << "\nGeneration,Best Fitness\n";
        for (int i = 0; i < best_list.size(); ++i) {
            file << i << "," << best_list[i] << "\n";
        }
        file.close();
        cout << "Results saved to results_cuda.csv" << endl;
    }

    auto end_time = chrono::high_resolution_clock::now();
    chrono::duration<double> elapsed_time = end_time - start_time;
    cout << "Program execution time: " << elapsed_time.count() << " seconds" << endl;

    return 0;
}
