import pandas as pd 
import os
from matplotlib import pyplot as plt

i=0
i2=0
df=None
df_original=None 

for file in os.listdir():
    if "result" in file:
        print(file)
        if df is None:
            df=pd.read_csv(file,header=0) #
        else : 
            tdf=pd.read_csv(file,header=0) #
            df=df+tdf
        i=i+1
    if "old" in file :
        print(file)
        if df_original is None:
            df_original=pd.read_csv(file,header=0) #
        else : 
            tdf=pd.read_csv(file,header=0) #
            df_original=df_original+tdf
        i2=i2+1

df=df/(i)
df_original=(df_original/i2) 
df.to_csv("results.csv",index=False)
df_original.to_csv("old.csv",index=False)
df.head()
df_original.head()
print(df)
print()
print(df_original)
print()
print(df[0:3])
print()
print(df[4:7])


label_y = ['Throughput', 'Average Delay', 'Delivery Ratio','Drop Ratio','Energy Consumption']
unit = {'Throughput':'(bit/sec)', 'Average Delay': '(sec)', 'Delivery Ratio':'', 'Drop Ratio':'','Energy Consumption': '(Joules)'}

for ly in label_y :
    plt.plot(df['Speed'][0:4],df[ly][0:4],'-o', label="BEEDSR") 
    plt.plot(df_original['Speed'][0:4],df_original[ly][0:4],'-o',label="DSR")
    plt.title(ly+" "+unit[ly]+" vs Speed(m/s)") 
    plt.xlabel('Speed (m/s)')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    plt.legend()
    # plt.show()
    plt.savefig('graphs/Speed vs. '+ly+'.png',bbox_inches='tight')
    plt.close()

for ly in label_y :
    plt.plot(df['Packet Size'][4:8],df[ly][4:8],'-o',label="BEEDSR")
    plt.plot(df_original['Packet Size'][4:8],df_original[ly][4:8],'-o',label="DSR")
    plt.title(ly+" "+unit[ly]+" vs Packet Size (byte) ") 
    plt.xlabel('Packet Size(byte)')
    plt.ylabel(ly+" "+unit[ly])
    plt.grid()
    plt.legend()
    # plt.show()
    plt.savefig('graphs/Packet size vs. '+ly+'.png',bbox_inches='tight')
    plt.close()


