import random
f=open("random.txt",'w')
for k in range(2**21):
    print(hex(random.randint(2**253,2**254))[2:],file=f)
f.close()