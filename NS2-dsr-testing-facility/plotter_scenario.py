import pandas as pd 
import os
from matplotlib import pyplot as plt

i=0
df=None

for file in os.listdir():
    if "result" in file:
        print(file)
        if df is None:
            df=pd.read_csv(file,header=0) #
        else : 
            tdf=pd.read_csv(file,header=0) #
            df=df+tdf
        i=i+1

df=df/(i) 
df.to_csv("results.csv",index=False)
df.head()

label_y = ['Throughput', 'Average Delay', 'Delivery Ratio','Drop Ratio','Energy Consumption']
unit = {'Throughput':'(bit/sec)', 'Average Delay': '(sec)', 'Delivery Ratio':'', 'Drop Ratio':'','Energy Consumption': 'Joules'}

for ly in label_y :
    plt.plot(df['Speed'][0:3],df[ly][0:3])
    plt.title(ly+" "+unit[ly]+" vs Speed(m/s)") 
    plt.xlabel('Speed (m/s)')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    # plt.show()
    plt.savefig('graphs/Speed vs. '+ly+'.png',bbox_inches='tight')
    plt.close()

for ly in label_y :
    plt.plot(df['Packet Size'][4:7],df[ly][4:7])
    plt.title(ly+" "+unit[ly]+" vs Packet Size (byte) ") 
    plt.xlabel('Packet Size(byte)')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    # plt.show()
    plt.savefig('graphs/Packet size vs. '+ly+'.png',bbox_inches='tight')
    plt.close()


