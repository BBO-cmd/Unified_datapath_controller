using namespace std;

#include <iostream>
#include <vector>

// Standard Convolution Function
std::vector<std::vector<int>> standardConvolution(const std::vector<std::vector<int>>& input, const std::vector<std::vector<int>>& filter) {
    int inputSize = 4;
    int filterSize = 3;
    int outputSize = inputSize - filterSize + 1;
    std::vector<std::vector<int>> output(outputSize, std::vector<int>(outputSize, 0));

    for (int i = 0; i < outputSize; ++i) {
        for (int j = 0; j < outputSize; ++j) {
            int sum = 0;
            for (int k = 0; k < filterSize; ++k) {
                for (int l = 0; l < filterSize; ++l) {
                    sum += input[i + k][j + l] * filter[k][l];
                }
            }
            output[i][j] = sum;
        }
    }
    return output;
}


// Function to perform matrix multiplication
std::vector<std::vector<float>> matrix_multiply(const std::vector<std::vector<float>>& mat1, const std::vector<std::vector<float>>& mat2) {
    float rows1 = mat1.size();
    float cols1 = mat1[0].size();
    float cols2 = mat2[0].size();

    std::vector<std::vector<float>> result(rows1, std::vector<float>(cols2, 0));

    for (float i = 0; i < rows1; ++i) {
        for (float j = 0; j < cols2; ++j) {
            for (float k = 0; k < cols1; ++k) {
                result[i][j] += mat1[i][k] * mat2[k][j];
            }
        }
    }
    return result;
}


// Function to calculate the transpose of a matrix
std::vector<std::vector<float>> transpose(const std::vector<std::vector<float>>& mat) {
    float rows = mat.size();
    float cols = mat[0].size();

    std::vector<std::vector<float>> result(cols, std::vector<float>(rows, 0));

    for (float i = 0; i < rows; ++i) {
        for (float j = 0; j < cols; ++j) {
            result[j][i] = mat[i][j];
        }
    }
    return result;
}




// Winograd Convolution Function
std::vector<std::vector<int>> winogradConvolution(const std::vector<std::vector<float>>& input, const std::vector<std::vector<float>>& filter) {
    // Assuming a simple Winograd convolution implementation

    std::vector<std::vector<float>> G = { {1, 0, 0},
                                        {0.5f, 0.5f, 0.5f},
                                        {0.5f, -0.5f, 0.5f},
                                        {0, 0, 1} };


    std::vector<std::vector<float>> Gg = matrix_multiply(G, filter);
    std::vector<std::vector<float>> G_transpose = transpose(G);
    std::vector<std::vector<float>> result1 = matrix_multiply(Gg, G_transpose);




    std::vector<std::vector<float>> B_transpose = { {1, 0, -1, 0},
                                         {0, 1, 1, 0},
                                         {0, -1, 1, 0},
                                         {0, 1, 0, -1} };


    std::vector<std::vector<float>> B_td = matrix_multiply(B_transpose, input);
    std::vector<std::vector<float>> B = transpose(B_transpose);
    std::vector<std::vector<float>> result2 = matrix_multiply(B_td, B);


    std::vector<std::vector<float>> M;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            M[i][j] = result1[i][j] * result2[i][j];
        }

    }


    std::vector<std::vector<float>> A_transpose = { {1, 1, 1, 0},
                                                     {0, 1, -1, -1} };
    std::vector<std::vector<float>> A_tM = matrix_multiply(A_transpose, M);
    std::vector<std::vector<float>> A = transpose(A_transpose);
    std::vector<std::vector<float>> result3 = matrix_multiply(A_tM, A);

    std::cout << "if this is printed, well executed" << endl;

    return result3;
}

int main() {
    // Input data (4x4)
    std::vector<std::vector<float>> input = {
        {1, 1, 1, 1},
        {2, 2, 2, 2},
        {3, 3, 3 , 3},
        {4, 4, 4, 4}
    };

    // Filter (3x3)
    std::vector<std::vector<float>>  filter = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8,9}
    };

    // Perform standard convolution
    std::vector < std::vector<float> > standardResult = standardConvolution(input, filter);

    // Perform Winograd convolution
    std::vector<std::vector<float>> winogradResult = winogradConvolution(input, filter);

    // Compare results
    std::cout << "Standard Convolution Result:" << std::endl;
    for (const auto& row : standardResult) {
        for (int val : row) {
            std::cout << val << " ";
        }
        std::cout << std::endl;
    }

    std::cout << "Winograd Convolution Result:" << std::endl;
    for (const auto& row : winogradResult) {
        for (int val : row) {
            std::cout << val << " ";
        }
        std::cout << std::endl;
    }

    // Check if results match
    if (standardResult == winogradResult) {
        std::cout << "Results Match!" << std::endl;
    }
    else {
        std::cout << "Results Do Not Match!" << std::endl;
    }

    return 0;
}
