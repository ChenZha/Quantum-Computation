a=[1.1234254,2,3,4]
b='{:.4f}'
print('a'.join([b.format(n) for n in a]))

print(('%.4f'*len(a))%(1,2,3,4))