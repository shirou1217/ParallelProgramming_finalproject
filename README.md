# Firefly Algorithm CUDA Optimization

## Project Overview
This project focuses on optimizing the Firefly Algorithm using CUDA parallel computing technology. The Firefly Algorithm is a nature-inspired metaheuristic algorithm that has applications in routing, navigation, renewable energy optimization, gene regulatory network modeling, drug design, and image processing. While it offers higher prediction accuracy compared to Particle Swarm Optimization, its execution time is significantly longer due to its high time complexity:

```
Time Complexity = Training Iterations * Number of Fireflies * Space Dimensions * Number of Fireflies
```

Our team "parallel-minds" from National Tsing Hua University successfully optimized this algorithm, achieving a 9x speedup compared to CPU-based implementations.

## Technologies & Tools Used
- **CUDA**: Utilized for GPU-accelerated parallel computing
- **C/C++**: Core programming languages for implementation
- **GPU Programming**: Leveraged GPU architecture for massive parallelism
- **Performance Profiling**: Analyzed and measured execution time and energy consumption
- **Algorithm Optimization**: Applied parallel computing principles to a complex metaheuristic algorithm

## Implementation Details
- **Parallelization Strategy**: Transformed the sequential Firefly Algorithm into a parallel implementation
- **Memory Management**: Optimized data transfer between CPU and GPU
- **Thread Organization**: Designed efficient thread blocks and grids for CUDA execution
- **Synchronization Techniques**: Implemented appropriate synchronization mechanisms for parallel execution
- **Resource Utilization**: Optimized GPU resource usage for maximum performance

## Results & Achievements
- **9x Speedup**: Achieved significant performance improvement compared to full-resource utilization on 2 CPUs
- **10x Power Efficiency**: Reduced energy consumption while improving performance
- **Scalability**: The optimization benefits scale with the number of fireflies, dimensions, and training iterations
- **Test Configuration**: Benchmarked with 512 simulated fireflies, 1024 space dimensions, and 3 training iterations

## Knowledge & Skills Gained
- **Parallel Algorithm Design**: Learned to transform sequential algorithms into parallel ones
- **CUDA Programming Model**: Mastered CUDA programming concepts and best practices
- **Performance Optimization**: Developed skills in identifying and resolving performance bottlenecks
- **Computational Thinking**: Enhanced ability to decompose complex problems for parallel processing
- **Benchmarking & Analysis**: Gained experience in measuring and evaluating performance metrics
- **Scientific Computing**: Applied parallel computing to solve real-world scientific problems

## Team Members
- 程詩柔
- 謝知豫
- 熊恩伶

## Mentorship
- Reese Wang

## References
- Textbook: "Nature-Inspired Computation in Navigation and Routing Problems Algorithms, Methods and Applications"
