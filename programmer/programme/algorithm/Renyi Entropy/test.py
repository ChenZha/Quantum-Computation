def funcfilter(x,xmap={}):
    xstr = [''.join(x),''.join(x[::-1])]

    boolin = xstr[0] in xmap or xstr[1] in xmap
    xmap[xstr[0]]=1
    xmap[xstr[1]]=1
    return (not boolin)
all_inistate  = [['0','0','0','1'],['1','0','0','0'],['0','1','0','0']]
all_inistate=list(filter(funcfilter,all_inistate))
print(all_inistate)