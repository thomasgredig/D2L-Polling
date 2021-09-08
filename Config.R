###################
## CONFIGURATION ##
###################

path.poll = '../Polling'
file.list = dir(path.poll, pattern='^\\d')           # polling files from Zoom
file.students = dir(path.poll, pattern='^P')[1]      # D2L student list
OUTPUT_D2L = file.path(path.poll,'polling-all.csv')  # output file with results
