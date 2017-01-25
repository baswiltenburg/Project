# -*- coding: utf-8 -*-

import os
os.chdir('/home/ubuntu/Project/Python')
output = open('output.csv', 'w')
a=[] #list with header elements
b=[] #list with data
readfile=open('data/data.csv', 'r')
for line in readfile:
    l = line.split(",")
    if len(l) == 19: 
        l.remove(l[12])
    b += [[l[0], l[3], l[11], l[13], l[15], l[16],l[17]]]
print b
    