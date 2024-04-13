#c-curve
from turtle import *

color('red')
begin_fill()
rule = ['R','F','L','L','F','R']
prev = ['R','F','L','L','F','R']
ans = []
for iter in range(4):
    ans = []
    for i in prev:
        if(i=='F'):
            ans+=rule
        else:
            ans.append(i)
    prev = ans
print(ans)

for i in range(0,len(ans)):
    if(ans[i] == 'R'):
        right(45)
    elif(ans[i] == 'F'):
        forward(20)
    elif(ans[i] == 'L'):
        left(45)


end_fill()
done()
