# RASPI Camera

## To take a still picture, in the terminal, type the following:
raspistill -o mypicture.png
fswebcam -d /dev/video0 --png 1  -F 10  test.png
ssocr  crop  182 91 139 38 -d -1  test.png -t 19

## record video
raspivid -o myvideo.h264

This will record a 5 second video be default, but you can specify the time with, for example, -t 10000, which will record for 10,000 milliseconds, or 10 seconds.  

## READING CODES FROM RSA SECUREID TOKEN

<https://smallhacks.wordpress.com/2012/11/11/reading-codes-from-rsa-secureid-token/> 

