import pandas as pd 
from matplotlib import pyplot as plt

df=pd.read_csv("results.csv",header=0)

df.head()

label_y = ['Throughput', 'Average Delay', 'Delivery Ratio','Drop Ratio']
unit = {'Throughput':'(bit/sec)', 'Average Delay': '(sec)', 'Delivery Ratio':'', 'Drop Ratio':''}

for ly in label_y :
    plt.plot(df['Nodes'][0:4],df[ly][0:4])
    plt.title(ly+" "+unit[ly]+" vs Number of Nodes") 
    plt.xlabel('Nodes')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    plt.show()

for ly in label_y :
    plt.plot(df['Flows'][5:9],df[ly][5:9])
    plt.title(ly+" "+unit[ly]+" vs Number of Flows") 
    plt.xlabel('Flows')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    plt.show()

for ly in label_y :
    plt.plot(df['Area'][10:],df[ly][10:])
    plt.title(ly+" "+unit[ly]+" vs Area(sq. m)") 
    plt.xlabel('Area(sq. m)')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    plt.show()


