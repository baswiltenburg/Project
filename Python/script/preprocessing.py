def preprocessing():
    import os 
    import urllib
    import pandas as pd
    from rpy2.robjects import pandas2ri
    pandas2ri.activate()
  
    a=[] #list with header elements
    b=[] #list with data
    readfile=open('data/data.csv', 'r')
    n = "No Data"    
    for line in readfile: 
        l = line.split(",")
        l = [item.strip('\n') for item in l]
        l = [item.strip('"') for item in l]    
            
        if l[0] == 'Date': 
            a += [l[0], l[3], l[4], l[11], l[13], l[15], l[16],l[17]] 
        else:
            if l[11] != '':
                b += [[l[0], l[3], l[4], l[11], l[14], l[16], l[17],l[18]]] 
            else:
                b += [[l[0], l[3], l[4], n, l[13], l[15], l[16],l[17]]] 

    coordinates = []
    for row in b:
        lat = row[6]
        lon = row[7]
        coordinates += [(lat, lon)]
        
    dic = {}
    for column in range(len(a)):
        lijst = []
        for i in range(len(b)): 
            lijst += [b[i][column]]
            dic[a[column]]=lijst 
    
    df = pd.DataFrame(dic)
    df_r = pandas2ri.py2ri(df)
    
    output = "output"
    if not os.path.exists(output):
        os.makedirs(output)
    with open("output/preprocessing_results.csv","w") as f:
        f.write(",".join(dic.keys()) + "\n")
        for row in zip(*dic.values()):
            f.write(",".join(str(n) for n in row) + "\n")
        f.close()   
            




        