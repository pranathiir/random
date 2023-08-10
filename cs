import numpy as np
def normalize(x):
    fac = abs(x).max()
    x1 = x / x.max()
    return fac, x1

arr=[]
n=int(input("enter order"))
for i in range(n*n):
    g=int(input("enter element "))
    arr.append(g)
a1=np.array(arr)
a=a1.reshape(n,n)
print(a)
x = []
for i in range(n):
    x.append(1)
x=np.array(x)
print(x)

def invert_matrix(matrix):
    n = len(matrix)    
    augmatrix = np.hstack((matrix, np.identity(n)))
    for i in range(n):
        scale_factor = augmatrix[i][i]
        augmatrix[i] /= scale_factor
        for j in range(n):
            if j != i:
                factor = augmatrix[j][i]
                augmatrix[j] -= factor * augmatrix[i]    
    inverse_matrix = augmatrix[:, n:]
    return inverse_matrix

c=invert_matrix(a)
for i in range(8):
    x = np.dot(c, x)
    lambda1, x = normalize(x)
    
print('Eigenvalue:', lambda1)
print('Eigenvector:', x)
