## Small datasets for examples and tests, built into the module (no files to find at run time).
##
## - `planets`: the eight planets, from NASA's Planetary Fact Sheet (public domain).
## - `exibble`: gt's tiny "example tibble", a column of each type (MIT, from gt / Great Tables).
## - `tavolaPitagorica(n)`: the times table, *la tavola pitagorica*, as every Italian pupil knows it.

import core

const planetsCsv* = """planet,type,mass,diameter,density,gravity,day_length,distance,orbital_period,mean_temp,moons,rings
Mercury,Terrestrial,0.330,4879,5429,3.7,4222.6,57.9,88.0,167,0,false
Venus,Terrestrial,4.87,12104,5243,8.9,2802.0,108.2,224.7,464,0,false
Earth,Terrestrial,5.97,12756,5514,9.8,24.0,149.6,365.2,15,1,false
Mars,Terrestrial,0.642,6792,3934,3.7,24.7,228.0,687.0,-65,2,false
Jupiter,Gas giant,1898,142984,1326,23.1,9.9,778.5,4331,-110,95,true
Saturn,Gas giant,568,120536,687,9.0,10.7,1432.0,10747,-140,146,true
Uranus,Ice giant,86.8,51118,1270,8.7,17.2,2867.0,30589,-195,28,true
Neptune,Ice giant,102,49528,1638,11.0,16.1,4515.0,59800,-200,16,true
"""
  ## Units: mass 10^24 kg, diameter km, density kg/m³, gravity m/s², day length hours,
  ## distance from the Sun 10^6 km, orbital period days, mean temperature °C. Known moons as
  ## of the 2024 fact sheet (the counts keep growing).

const exibbleCsv* = """num,char,fctr,date,time,datetime,currency,row,group
0.1111,apricot,one,2015-01-15,13:35,2018-01-01 02:22,49.95,row_1,grp_a
2.222,banana,two,2015-02-15,14:40,2018-02-02 14:33,17.95,row_2,grp_a
33.33,coconut,three,2015-03-15,15:45,2018-03-03 03:44,1.39,row_3,grp_a
444.4,durian,four,2015-04-15,16:50,2018-04-04 15:55,65100,row_4,grp_a
5550,,five,2015-05-15,17:55,2018-05-05 04:00,1325.81,row_5,grp_b
,fig,six,2015-06-15,,2018-06-06 16:11,13.255,row_6,grp_b
777000,grapefruit,seven,,19:10,2018-07-07 05:22,,row_7,grp_b
8880000,honeydew,eight,2015-08-15,20:20,,0.44,row_8,grp_b
"""

proc planets*(): TableData = parseCsv(planetsCsv)
proc exibble*(): TableData = parseCsv(exibbleCsv)

proc tavolaPitagorica*(n = 10): TableData =
  ## An n×n times table: a column `×` with 1..n, then one column per factor ("1" .. "n").
  result = TableData()
  var first: seq[Value]
  for i in 1 .. n: first.add toValue(i)
  result.addColumn("×", first)
  for j in 1 .. n:
    var col: seq[Value]
    for i in 1 .. n: col.add toValue(i * j)
    result.addColumn($j, col)
