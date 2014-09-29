import matplotlib as mpl
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cbook as cbook
import sys
import matplotlib.gridspec as gridspec
import matplotlib.mlab as mlab
import math

gs = gridspec.GridSpec(2, 2)

messageData = np.loadtxt('../../websocket_client/messages.txt', delimiter=",")
lagData = np.loadtxt('../../websocket_client/lag.txt', delimiter=",")

totalSimulationTime = 3000
nRooms = 1500

roomArray = [0] * nRooms
avgMessages = [0] * nRooms
avgLag = [0] * nRooms

x = messageData[:, 0]

# The actual time available for a given room is total time minus the process time.
# This is because each room is delayed by 1 second.
for i in range(len(x)):
  proc = int(x[i]) -1
  avgMessages[proc] = messageData[proc,1]/(totalSimulationTime - messageData[proc,0])
  roomArray[proc] = proc + 1
  avgLag[proc] = lagData[proc, 1]/1000

avgUser = 25.5

print "Mean lag:", np.mean(avgLag), "ms"
print "Standard Deviation:", np.std(avgLag), "ms"
print "Max lag:", np.amax(avgLag),"ms"
print "Min lag:", np.amin(avgLag),"ms"

print "Average Message Throughput: ", (np.mean(avgMessages))/avgUser
print "Std Dev:", (np.std(avgMessages)/avgUser)
print "Max Throughput:", (np.amax(avgMessages)/avgUser)
print "Min Throughput:", (np.amin(avgMessages)/avgUser)

if sys.argv[2] == "--noplot":
  print "******"
else:
  ax1 = plt.subplot(gs[0,:])
  ax3 = plt.subplot(gs[1, :])

  ax1.bar(roomArray, avgMessages, facecolor = 'green', edgecolor="none", align="center")
  ax1.set_xlabel('Rooms', fontsize = 18)
  ax1.set_ylabel('Avg messages/second/room', fontsize =18)
  ax1.set_title('Message Rate', fontsize = 20)

  ax3.bar(roomArray, avgLag, facecolor = 'green', edgecolor="none", align="center")
  ax3.set_xlabel('Rooms', fontsize = 18)
  ax3.set_ylabel('Average lag (ms)', fontsize =18)
  ax3.set_title('Distribution of lag times', fontsize = 20)

  ax1.set_xlim([1,1000])
  ax3.set_xlim([1, 1000])

  plt.show()
