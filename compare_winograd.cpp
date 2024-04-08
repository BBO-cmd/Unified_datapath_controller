using namespace std;

#include <iostream>
#include <vector>

 vector< vector<float>> standardConvolution( vector< vector<float>> input,  vector< vector<float>> filter) {
    int inputSize = 4;
    int filterSize = 3;
    int outputSize = inputSize - filterSize + 1;
     vector< vector<float>> output(outputSize,  vector<float>(outputSize, 0));

    for (float i = 0; i < outputSize; i++) {
        for (float j = 0; j < outputSize; j++) {
            float sum = 0;

            for (float k = 0; k < filterSize; k++) {
                for (float l = 0; l < filterSize; l++) {
                    sum += input[i + k][j + l] * filter[k][l];
                }
            }
            output[i][j] = sum;
        }
    }
    return output;
}

 vector< vector<float>> matrix_multiply( vector< vector<float>> mat1,  vector< vector<float>> mat2) {
    float rows1 = mat1.size();
    float cols1 = mat1[0].size();
    float cols2 = mat2[0].size();

     vector< vector<float>> result(rows1,  vector<float>(cols2, 0));

    for (float i = 0; i < rows1; i++) {
        for (float j = 0; j < cols2; j++) {
            for (float k = 0; k < cols1;k ++) {
                result[i][j] += mat1[i][k] * mat2[k][j];
            }
        }
    }


    return result;
}


 vector< vector<float>> transpose( vector< vector<float>>mat) {
    float rows = mat.size();
    float cols = mat[0].size();

     vector< vector<float>> result(cols,  vector<float>(rows, 0));

    for (float i = 0; i < rows; ++i) {
        for (float j = 0; j < cols; ++j) {
            result[j][i] = mat[i][j];
        }
    }
    return result;
}


 vector< vector<float>> winogradConvolution(vector< vector<float>> input, vector< vector<float>> filter) {

     vector< vector<float>> G = 
     /*{ {1, 0, 0},
                                        {0.5f, 0.5f, 0.5f},
                                        {0.5f, -0.5f, 0.5f},
                                        {0, 0, 1} };*/
     { {1,0,0}, {0.5f, -0.5f, 0.5f}, {0.5f, 0.5f, 0.5f}, {0,0,1} };


     vector< vector<float>> Gg = matrix_multiply(G, filter);
     vector< vector<float>> G_transpose = transpose(G);
     vector< vector<float>> result1 = matrix_multiply(Gg, G_transpose);

     cout << "Filter Transformation Output: " << endl;
     for (auto& row : result1) {
         for (int val : row) {
             cout << val << " ";
         }
         cout << endl;
     }




     vector< vector<float>> B_transpose = 
     //{ {1, 0, -1, 0},
     //                                    {0, 1, 1, 0},
     //                                    {0, -1, 1, 0},
     //                                    {0, 1, 0, -1} };
     { {-1, 0, 1, 0}, {0,1,-1,0}, {0,1,1,0}, {0,-1,0,1}};
     vector< vector<float>> B_td = matrix_multiply(B_transpose, input);
     vector< vector<float>> B = transpose(B_transpose);
     vector< vector<float>> result2 = matrix_multiply(B_td, B);


     cout << "Data Transformation Output: " << endl;
     for (auto& row : result2) {
         for (int val : row) {
             cout << val << " ";
         }
         cout << endl;
     }



     vector< vector<float>> M(4,  vector<float>(4, 0));
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            M[i][j] = result1[i][j] * result2[i][j];
        }

    }

    cout << "Elementwise mul Output: " << endl;
    for (auto& row : M) {
        for (int val : row) {
            cout << val << " ";
        }
        cout << endl;
    }



    vector< vector<float>> A_transpose =
        //{ {1, 1, 1, 0}, {0, 1, -1, -1} };
    { { -1, -1, 1, 0 },  { 0, 1, 1, 1, } };
     vector< vector<float>> A_tM = matrix_multiply(A_transpose, M);
     vector< vector<float>> A = transpose(A_transpose);
     vector< vector<float>> result3 = matrix_multiply(A_tM, A);

     //cout << "if this is printed, well executed" << endl;


     cout << "output transform Output: " << endl;
     for (auto& row : result3) {
         for (int val : row) {
             cout << val << " ";
         }
         cout << endl;
     }




    return result3;
}

int main() {
    // Input data (4x4)
     vector< vector<float>> input = {
        {4, 4, 4, 4},
        {3, 3, 3, 3},
        {2, 2, 2 , 2},
        {1, 1, 1, 1}
    };

    // Filter (3x3)
     vector< vector<float>>  filter = {
        {9, 8, 7},
        {6, 5, 4},
        {3, 2,1}
    };

     vector <vector<float> > standardResult = standardConvolution(input, filter);

     vector< vector<float>> winogradResult = winogradConvolution(input, filter);

    // Compare the two results
     cout << "Standard Convolution Result:" <<  endl;
    for (auto& row : standardResult) {
        for (int val : row) {
             cout << val << " ";
        }
         cout <<  endl;
    }

     cout << "Winograd Convolution Result:" <<  endl;
    for (auto& row : winogradResult) {
        for (int val : row) {
             cout << val << " ";
        }
         cout <<  endl;
    }

    // Check if results match
    if (standardResult == winogradResult) {
         cout << "SAME" <<  endl;
    }
    else {
         cout << "Does not match" <<  endl;
    }

    return 0;
}
