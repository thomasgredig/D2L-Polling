# D2L-Polling

Use Polling in Zoom, then convert the output files to D2L for Grade Export

## Setup

- Create a "general" [poll in Zoom](https://support.zoom.us/hc/en-us/articles/213756303-Polling-for-meetings) with answers (A),(B),(C),(D),(E), etc.
- Create a folder for the polling data and configure [Config.R](Config.R)
- Download the student list from D2L using Grade Export and save the file in the polling data folder (file should start with letter "P")
- Download the Zoom polling data files, files should start with a number, example: `81234221117_2021-01-25_PollReport.csv`
- Run [ZoomPoll-Analysis.R](ZoomPoll-Analysis.R) to generate output files in polling folder that can be imported to D2Ls
