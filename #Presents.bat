@echo off
@cd/d %~dp0
title Presents
set filePath=%1
set fileRoot=%~dp1
set fileName=%~n1
set fileExt=%~x1
set surffix=_placeholder




:MAIN
cls
echo [96m[Choose Action:][0m
echo 1 : Cut
echo 2 : Cut ^& Resize
echo 3 : Resize
echo 4 : Concat Videoes
echo 5 : Crop
echo 6 : Mute
echo 7 : Extract
echo 8 : Repack
echo t : Test

set /p k=[96m[Press Enter after typed the action number: [0m
cls

if /i %k%==1 GOTO Action1
if /i %k%==2 GOTO Action2
if /i %k%==3 GOTO Action3
if /i %k%==4 GOTO Action4
if /i %k%==5 GOTO Action5
if /i %k%==6 GOTO Action6
if /i %k%==7 GOTO Action7
if /i %k%==8 GOTO Action8
if /i %k%==t GOTO ActionTest
REM else
GOTO END




:Action1
echo [96m[Cut][0m

set surffix=_cut
set/p startTime=Start Time (e.g. 00:14:22 or 14:22): 
set/p toTime=To Time (e.g. 00:14:25 ro 14:25, cut piece will be 3 seconds long): 

if not defined startTime (set startTime=00:00:00)
if not defined toTime (set toTime=00:00:10)

set startTimeEs=%startTime::=\:%
set toTimeEs=%toTime::=\:%

if defined filePath (
	echo [96mPreviewing...press any key to process[0m
	
	ffplay  ^
		-i %filePath%  ^
		-vf "trim=start='%startTimeEs%':end='%toTimeEs%',setpts=PTS-STARTPTS" ^
		-af "atrim=start='%startTimeEs%':end='%toTimeEs%',asetpts=PTS-STARTPTS" ^
		2> nul
	
	pause
	
	ffmpeg  ^
		-i %filePath%  ^
		-ss %startTime%  ^
		-to %toTime%  ^
		-c copy  ^
		"%fileRoot%%fileName%%surffix%%fileExt%"
) else (
	GOTO NoFile
)
GOTO END




:Action2
echo [96m[Cut ^& Rezise][0m

set surffix=_cut^&resize
set/p startTime=Start Time (e.g. 00:14:22 or 14:22): 
set/p toTime=To Time (e.g. 00:14:25 ro 14:25, cut piece will be 3 seconds long): 
set/p scaleFactor=Scale (e.g. 0.5 for 50%%, 0.5 by default): 
set/p videoBitrate=Bitrate (e.g. 2000k for 2000 kpbs, 1500k by default): 
set/p outputExt=File extension (%fileExt% by default): 

if not defined startTime (set startTime=00:00:00)
if not defined toTime (set toTime=00:00:10)
if not defined scaleFactor (set scaleFactor=0.5)
if not defined videoBitrate (set videoBitrate=1500k)
if not defined outputExt (set outputExt=%fileExt%)

set startTimeEs=%startTime::=\:%
set toTimeEs=%toTime::=\:%

if defined filePath (
	echo [96mPreviewing...press any key to process[0m
	
	ffplay  ^
		-i %filePath%  ^
		-vf "trim=start='%startTimeEs%':end='%toTimeEs%',setpts=PTS-STARTPTS,scale=iw*%scaleFactor%:ih*%scaleFactor%" ^
		-af "atrim=start='%startTimeEs%':end='%toTimeEs%',asetpts=PTS-STARTPTS" ^
		2> nul
	
	pause
	
	ffmpeg  ^
		-ss %startTime%  ^
		-to %toTime%  ^
		-i %filePath%  ^
		-c:a copy  ^
		-b:v %videoBitrate%  ^
		-vf "scale=iw*%scaleFactor%:ih*%scaleFactor%"  ^
		-c:v h264_nvenc  ^
		"%fileRoot%%fileName%%surffix%%outputExt%"
) else (
	GOTO NoFile
)
GOTO END




:Action3
echo [96m[Rezise][0m

set surffix=_resize
set/p scaleFactor=Scale (e.g. 0.5 for 50%%, 0.5 by default): 
set/p videoBitrate=Bitrate (e.g. 2000k for 2000 kpbs, 1500k by default): 
set/p outputExt=File extension (%fileExt% by default): 

if not defined scaleFactor (set scaleFactor=0.5)
if not defined videoBitrate (set videoBitrate=1500k)
if not defined outputExt (set outputExt=%fileExt%)

if defined filePath (
	ffmpeg  ^
		-i %filePath%  ^
		-c:a copy ^
		-b:v %videoBitrate% ^
		-vf "scale=iw*%scaleFactor%:ih*%scaleFactor%"  ^
		-c:v h264_nvenc  ^
		"%fileRoot%%fileName%%surffix%%outputExt%"
) else (
	GOTO NoFile
)
GOTO END




:Action4
echo [96m[Concat][0m
echo [93mConcat don't use drag drop files, place them All in [96mConcat[93m folder[0m

pause

(for %%i in (Concat\*.*) do @echo file '%%i') > Concat.txt

ffmpeg  ^
	-f concat  ^
	-safe 0  ^
	-i Concat.txt  ^
	-c copy  ^
	output_concat.mp4
	
del Concat.txt

GOTO END




:Action5
echo [96m[Crop][0m

set surffix=_crop
REM Check file:///C:/App/Something/FFmpeg/doc/ffmpeg-filters.html#crop
echo Crop string (e.g. 80:60:200:100 for 80¡Á60 section at (200, 100)
set/p cropStr=("iw:ih:0:0" by default): 
set/p videoBitrate=Bitrate (e.g. 2000k for 2000 kpbs, 1500k by default): 
set/p outputExt=File extension (%fileExt% by default): 

if not defined cropStr (set cropStr=iw:ih:0:0)
if not defined videoBitrate (set videoBitrate=1500k)
if not defined outputExt (set outputExt=%fileExt%)

if defined filePath (
	echo [96mPreviewing...press any key to process[0m
	
	ffplay  ^
		-i %filePath%  ^
		-vf "crop=%cropStr%" ^
		2> nul
	
	pause
	
	ffmpeg  ^
		-i %filePath%  ^
		-c:a copy ^
		-b:v %videoBitrate% ^
		-vf "crop=%cropStr%"  ^
		-c:v h264_nvenc  ^
		"%fileRoot%%fileName%%surffix%%outputExt%"
) else (
	GOTO NoFile
)
GOTO END




:Action6
echo [96m[Mute][0m
set surffix=_mute

if defined filePath (
	ffmpeg ^
		-i %filePath%  ^
		-an ^
		-c:v copy ^
		"%fileRoot%%fileName%%surffix%%fileExt%"
) else (
	GOTO NoFile
)
GOTO END




:Action7
echo [96m[Extract][0m

set/p videoExt=Video extension (without dot, default MP4):
set/p audioExt=Audio extension (without dot, default M4A):

if not defined videoExt (set videoExt=mp4)
if not defined audioExt (set audioExt=m4a)

if defined filePath (
	ffmpeg ^
		-i %filePath% ^
		-c:a copy ^
		-vn ^
		"%fileRoot%%fileName%_audio.%audioExt%" ^
		-c:v copy ^
		-an ^
		"%fileRoot%%fileName%_video.%videoExt%"
) else (
	GOTO NoFile
)
GOTO END




:Action8
echo [96m[Repack][0m
set surffix=_repack

set/p outputExt=File extension (.mkv by default): 

if not defined outputExt (set outputExt=.mkv)

if defined filePath (
	ffmpeg  ^
		-i %filePath%  ^
		-c:a copy ^
		-c:v copy  ^
		"%fileRoot%%fileName%%surffix%%outputExt%"
) else (
	GOTO NoFile
)
GOTO END




:ActionTest
echo [96m[Test][0m
set surffix=_test

if defined filePath (
	ffmpeg ^
		-i %filePath%  ^
		-an ^
		-c:v copy ^
		"%fileRoot%%fileName%%surffix%%fileExt%"
) else (
	GOTO NoFile
)
GOTO END




:NoFile
echo [91mNo file found, drop file to this bat.[0m




:END
echo [96mFinished.[0m
pause