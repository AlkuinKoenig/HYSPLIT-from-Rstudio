Alkuin Koenig 2023/07/31
alkuin.koenig@gmx.de

This is a bugfix for the excellent splitr library. There were some bugs with missing meteorological files for certain cases:
1)"weird gap year dates", like 29.02.2012
2) Trajectories starting at 22:00 or 23:00, on the date corresponding to the last date of a given meteorological filename (the issue was at least encountered for gdas1 runs)

The issues could be fixed by being more generous with the meterological files that have to be imported. The library will now always attempt to pull "1 more day of meteorological input than it would, in theory, need". E.g, if a backward computation starts on 15.01.2012, the library will make sure that meteorological input for 16.01.2012 (at least) is also available. 

all changes made to the original library are marked with comments starting with "AK"

