#!/usr/bin/env python
import sys
import subprocess
import math
import matplotlib.pyplot as plot
from matplotlib import pyplot

# Ramer Douglas Peucker algorithm
# Implementation of Ramer Douglas Peucker algorithm and plot Polygon

x = []
y = []
new_x = []
new_y = []

print "\n\t\tRamer Douglas Peucker algorithm "


def main():
    if(len(sys.argv) < 2):
        print "Pass File as Parameter"
        sys.exit(0)
    obj = open(sys.argv[1], "r")
    if(len(sys.argv) < 3):
        print "Pass epsilon as parameter ( epsilon > 0 )"
        sys.exit(0)
    else:
        epsilon = float(sys.argv[2])
    data = obj.readlines()
    data = data[2]
    data = data[1:-3]
    data = data.split("|")
    city_name = data[0]
    city_area = data[1]
    city_area = city_area[1:]
    PointList = data[2]

    PointList = PointList[1:]
    PointList = PointList.split("(")
    PointList = PointList[2]
    PointList = PointList.split(",")
    for i in range(0, len(PointList) - 1):
        lst = PointList[i].split(" ")
        x.append(lst[0])
        y.append(lst[1])

    if(epsilon <= 0):
        print "epsilon should be greater than 0"
        sys.exit(0)
    if((epsilon < 1500) and (epsilon > 0)):
        plot.plot(x, y)
        plot.savefig("Output_Polygon.png")
        sys.exit(0)

    lst = RDP(x, y, epsilon)
    for i in range(0, len(lst)):
        new_lst = lst[i].split(",")
        if((i % 2) == 0):
            new_x.append(new_lst[0])
        else:
            new_y.append(new_lst[0])

    maxx = max(new_x)

    for i in range(0, len(new_x)):
        new_x[i] = float(new_x[i])
        new_y[i] = float(new_y[i])

    plot.plot(new_x, new_y)
    plot.savefig("Output_Polygon.png")


def RDP(x, y, epsilon):
    # Find the point with maximum distance
    dmax = 0
    index = 0
    end = len(x) - 1

    # Line segment is x[0],y[0],x[end],y[end]
    for i in range(1, end):
        d = shortestDistanceToSegment(x[i], y[i], x[0], y[0], x[end], y[end])
        if (d > dmax):
            index = i
            dmax = d

    ResultList = []
    # If max distance is greater than epsilon , recursively simplify
    if(dmax > epsilon):
        recResults1 = RDP(x[:index], y[:index], epsilon)
        recResults2 = RDP(x[index:-1], y[index:-1], epsilon)
        ResultList = []
        for point in recResults1 + recResults2:
            if point not in ResultList:
                ResultList.append(point)
    else:
        ResultList = []
        ResultList += [x[0]] + [y[0]] + [x[end]] + [y[end]]
    return ResultList


def shortestDistanceToSegment(xi, yi, x0, y0, xend, yend):
    dx = float(xend) - float(x0)
    dy = float(yend) - float(y0)
    denominator = math.sqrt((dy * dy) + (dx * dx))
    numerator = math.fabs((dy * float(xi)) - (dx * float(yi)) +
                          (float(xend) * float(y0)) - (float(yend) * float(x0)))
    distance = numerator / denominator
    return distance

main()
