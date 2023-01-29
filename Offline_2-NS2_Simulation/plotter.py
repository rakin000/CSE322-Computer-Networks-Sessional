import pandas as pd 
from matplotlib import pyplot as plt

df=pd.read_csv("results.csv",header=0)

df.head()

label_y = ['Throughput', 'Average Delay', 'Delivery Ratio','Drop Ratio']


for ly in label_y :
    plt.plot(df['Nodes'][0:4],df[ly][0:4])
    plt.title("Nodes vs "+ly) 
    plt.xlabel('Nodes')
    plt.ylabel(ly)
    plt.show()

for ly in label_y :
    plt.plot(df['Flows'][5:9],df[ly][5:9])
    plt.title("Flows vs "+ly) 
    plt.xlabel('Flows')
    plt.ylabel(ly)
    plt.show()

for ly in label_y :
    plt.plot(df['Area'][10:],df[ly][10:])
    plt.title("Area vs "+ly) 
    plt.xlabel('Area')
    plt.ylabel(ly)
    plt.show()


