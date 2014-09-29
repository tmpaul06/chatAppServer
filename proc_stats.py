import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cbook as cbook
import sys
import matplotlib.gridspec as gridspec
import matplotlib.mlab as mlab
import math

gs = gridspec.GridSpec(2, 2)

def read_datafile(file_name):
    # the skiprows keyword is for heading, but I don't know if trailing lines
    # can be specified
    data = np.loadtxt(file_name)
    return data

data = read_datafile('mochimem.log')

data2 = np.loadtxt('../../websocket_client/clients.txt', delimiter = ",")

x = data[:,0]
y = data[:,1]/1024
z = data[:, 2]

histx = data2[:,1]

count = [0] * 50
users = [0] * 50
for k in range(len(count)):
  users[k] = k+1
print np.mean(users)
for j in range(len(histx)):
  p = int(histx[j])
  count[p - 1] = count[p - 1]+ 1

first = x[0]
for i in range(len(x)):
  x[i] = x[i] - first


ax1 = plt.subplot(gs[0,0])
ax2 = plt.subplot(gs[0, 1])
ax3 = plt.subplot(gs[1, :])

ax1.set_title("Benchmark results for " + sys.argv[1] +  " connections", fontsize = 20)    
ax1.set_xlabel('Elapsed Time (s)', fontsize = 18)
ax1.set_ylabel('Memory (MB)', fontsize = 18)

ax2.set_title("Benchmark results for " + sys.argv[1] +" connections", fontsize = 20)    
ax2.set_xlabel('Elapsed Time (s)', fontsize = 18)
ax2.set_ylabel('Connections', fontsize = 18)
ax2.set_ylim([0, 40000])

ax3.bar(users, count, facecolor = 'green', edgecolor="none", align="center")
ax3.set_xlabel('Users in a single room', fontsize = 18)
ax3.set_ylabel('Count', fontsize =18)
ax3.set_title('Distribution of users', fontsize = 20)
ax3.set_xticks(users)
ax3.set_ylim([0, 50])

ax1.plot(x,y, lw=3.0, c= 'black')
ax2.plot(x,z, lw=3.0, c = 'black')

leg = ax1.legend()
leg = ax2.legend()
plt.show()
