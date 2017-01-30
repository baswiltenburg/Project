import os
import csv
from rpy2.robjects import pandas2ri
pandas2ri.activate()
    
def read_data_fire_period():
    a=[] #list with header elements
    b=[] #list with data
    readfile=open('Dataframes/df_fire_period.csv', 'r')    
    for line in readfile: 
        l = line.split(",")
        l = [item.strip('\n') for item in l]
        l = [item.strip('"') for item in l]  
        if l[0] == '':
            a += l
            a[0] = "ROW_NR"
        else:
            b += [l]
    return a,b

header, b = read_data_fire_period()


def create_list_dates(b): 
    lijst = []
    for i in range(len(b)):
        for j in range(len(b[i])):
            if j == 8: 
                if b[i][j] not in lijst:
                    lijst += [b[i][j]]
    lijst.sort()
    return lijst
    
lijst = create_list_dates(b)   
    

def create_list_of_dataframes(b):
    lijst_dataframes = []
    for i in range(len(lijst)):
        lijst_dataframes += [[]]
        for j in range(len(b)):
            for k in range(len(b[j])):
                if k == 8: 
                    b[j][k] = str(b[j][k])
                    if lijst[i] == b[j][k]:
                        lijst_dataframes[i] += [b[j]]

    return lijst_dataframes

lijst_dataframes = create_list_of_dataframes(b)


def write_dataframes_to_csv(lijst_dataframes, header):
    for i in range(len(lijst_dataframes)):
        a = str(i) 
        day = 'day_'
        extensie = '.csv'
        path = 'Dataframes/'
        filename = path+day+a+extensie
        myfile = open(filename, 'wb')
        wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
        wr.writerow(header)
        for df in lijst_dataframes[i]:
            wr.writerow(df)
    os.remove('Dataframes/day_82.csv')
        
write_dataframes_to_csv(lijst_dataframes, header)

    

