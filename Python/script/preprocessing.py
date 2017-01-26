def preprocessing():
    import os 
    import urllib
    import pandas as pd
    import numpy as np
    from rpy2.robjects import pandas2ri
    pandas2ri.activate()
    from datetime import datetime
    
    data = "data"
    if not os.path.exists(data):
        os.makedirs(data)  
        #url = 'https://www3.epa.gov/cgi-bin/broker?_service=data&_server=134.67.99.91&_port=4090&_sessionid=FnJvt/WpO52&_PROGRAM=dataprog.ad_viz_plotval_getdata.sas'
        #filename = 'data/data.csv'
        #urllib.urlretrieve(url, filename)
    
    a=[] #list with header elements
    b=[] #list with data

    readfile=open('data/data.csv', 'r')
        
    for line in readfile:
        l = line.split(",")
        l = [item[1:-1].strip('"') for item in l]
        #print l  
        if len(l) == 19: 
            l.remove(l[12])
            b += [[l[0], l[3], l[11], l[13], l[15], l[16],l[17]]]    
        else:
            a += [l[0], l[3], l[11], l[13], l[15], l[16],l[17]]     
        print a

    coordinates = []
    for row in b:
        lat = float(row[5])
        lon = float(row[6])
        coordinates += [(row[5], row[6])]
        
    #dic = {}
   # for column in range(len(a)):
    #    lijst = []
    #    print a[column]
     #   for i in range(len(b)):  
     #       print i
     #       lijst += [b[i][column]]
     #       dic[a[column]]=lijst
        
    
   # df = pd.DataFrame(dic)
   # df_r = pandas2ri.py2ri(df)
    
    output = "output"
    if not os.path.exists(output):
        os.makedirs(output)  
    with open("output/preprocessed_data.csv","w") as f:
        f.write(",".join(dic.keys()) + "\n")
        for row in zip(*dic.values()):
            f.write(",".join(str(n) for n in row) + "\n")
    f.close()
preprocessing()

        