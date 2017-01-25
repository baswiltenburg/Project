# -*- coding: utf-8 -*-
import os
os.chdir('/home/ubuntu/Project/Python')
output = open('output.csv', 'w')
a=[] #list with header elements
b=[] #list with data
readfile=open('data/data.csv', 'r')
for line in readfile:
    l = line.split(",")
    l = [item[1:-1].strip('"') for item in l]
    print l
    #for i in l:
    #    i.replace('"','')
     #   print i
    
    if len(l) == 19: 
        l.remove(l[12])
        b += [[l[0], l[3], l[11], l[13], l[15], l[16],l[17]]]    
    else:
        a += [l[0], l[3], l[11], l[13], l[15], l[16],l[17]]       
#print a
#print b
coordinates = []
for row in b:
    print type(row[5])
    print type(row[6])  
    lat = float(row[5])
    lon = float(row[6])
    coordinates += [(row[5], row[6])]
print coordinates
print coordinates[0][1]
print b

import csv

dic = {}
for column in range(len(a)):
    lijst = []
    print a[column]    
    for i in range(len(b)):
        print b[i]
        lijst += [b[i][column]]
    print lijst
    dic[a[column]]=lijst
print dic

import pandas as pd
import numpy as np
from rpy2.robjects import pandas2ri
pandas2ri.activate()
from datetime import datetime

df = pd.DataFrame(dic)
print df

df_r = pandas2ri.py2ri(df)
print(type(df_r))
print(df_r)