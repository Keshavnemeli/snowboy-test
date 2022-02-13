# Snowboy
Based of this [repo](https://github.com/seasalt-ai/snowboy)
### Building the model
Record 3 wav files with your wakeword name them `record1.wav, record2.wav, record3.wav` .
    Make sure they are `16000 sample rate, 16 bits, 1 channel` . 
    Use  tool like [audacity](https://www.audacityteam.org/download/windows/) to record or convert to the above configuration. 
    If already reacorded, Follow this [tutorial](https://learn.adafruit.com/microcontroller-compatible-audio-file-conversion?view=all) to convert the files using audacity. Place these files in a `model` folder
    
To Build the image and running the container use this [Dockerfile](https://github.com/seasalt-ai/snowboy/blob/master/Dockerfile).

 **Build the image**
```sh
docker build -t snowboy-pmdl .
```
**Run the container**
When running the `-v` copies the model folder from your host to the container
```sh
docker run -it -v path/to/you/model:/snowboy-master/examples/Python/model snowboy-pmdl
```

You might get an error saying `ImportError: No module named snowboy` in this case we need to run the commands manually.

*To run the container manually*,
This is happening because the virtual environment snowboy is not getting activated using the dockerfile. Build the *ubuntu:16.04* image and run the container.
You can manually sh into the container and download/wget this [file](https://github.com/seasalt-ai/snowboy/archive/master.zip) (then unzip) or clone this [repo](https://github.com/seasalt-ai/snowboy) (this is the same repo as mentioned in the Dockerfile) and run the commands.

```sh
# After  running the container and downloading the snowboy repo, copy the model from host to the docker container
docker cp /path/to/model <containerId>:/snowboy-master/examples/Python/model 

#To sh into container
docker exec it <container-name> /bin/bash
```
```sh
#Inside the ubuntu container 

#Install dependencies
apt update && apt --yes --force-yes install wget unzip build-essential python python-dev virtualenv portaudio19-dev

#create virtual env if not created
cd /snowboy-master
virtualenv -p python2 venv/snowboy 

#Activate it and install requirements.txt. You'll see a (snowboy) in the shell path if the venv is activated.
. venv/snowboy/bin/activate
pip install -r requirements.txt

# Generate the model
cd /snowboy-master/examples/Python
python generate_pmdl.py -r1=model/record1.wav -r2=model/record2.wav -r3=model/record3.wav -lang=en -n=model/hotword.pmdl
```

This will generate the file in `model/hotword.pml`. Save or Download this file.



### Running the model
We are using a demo app that snowboy is proving to run the model. 
In a **64 bit Ubuntu 14.04** machine.

*Note: This ubuntu machine should have microphone and speaker devices attached with the appropriate drivers.*

*run the command `speaker-test` in the ubuntu machine to check for the speaker and install the drivers if they are not found.*

*If they aren't installed you'll get an error (no output devices) when we running `python demo.py` in the end. If we want to run it on a container we need to research on how to can we send audio stream from host device to the container.*

Download this [demo app](https://s3-us-west-2.amazonaws.com/snowboy2/snowboy-releases/ubuntu1404-x86_64-1.3.0.tar.bz2)
Install dependencies:

    sudo apt-get install python-pyaudio python3-pyaudio sox
    
    pip install pyaudio
    
    apt update && apt --yes --force-yes install wget unzip build-essential python python-dev virtualenv portaudio19-dev
    
Compile a supported swig version (3.0.10 or above)
    
    # download swig source code
    wget http://downloads.sourceforge.net/swig/swig-3.0.10.tar.gz
    
    sudo apt-get install libpcre3 libpcre3-dev
    
    # cd into the downloaded swig directory before running below commands
    ./configure --prefix=/usr                  \
            --without-clisp                    \
            --without-maximum-compile-warnings &&
    make
    make install &&
    install -v -m755 -d /usr/share/doc/swig-3.0.10 &&
    cp -v -R Doc/* /usr/share/doc/swig-3.0.10
    
Install these additional dependencies to aviod shared object file error or `GLIBCXX_3.4.20 not found` error: 
```
sudo apt-get install -y libatlas-base-dev libhdf5-dev libhdf5-serial-dev libatlas-base-dev libjasper-dev libqtgui4 libqt4-test

sudo apt update
sudo apt install software-properties-common
sudo apt update

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install gcc-4.9 g++-4.9
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9

sudo apt-get install libatlas-base-dev
```

cd into the demo app and run
```
pip install -r requirements.txt
```

Test the demo app
```
python demo.py resources/snowboy.umdl
```

This should say `listening..` and when you say the word `snowboy` it should detect it. 

To user personal model, Copy the generated model (hotword.pmdl) into resources folder and run the above python command with the `resources/hotword.pmdl` argument.  

If you are getting a `GLIBCXX_3.4.20' not found error`  run this command `strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX` to check if 3.4.20 is in the list if its not please update the gcc on the machine to 4.9. 

If you are getting any python realated import errors. Create a virtualenv in the demo app and run the env. Then run the demo.py.
```
virtualenv -p python2 venv/snowboy 
. venv/snowboy/bin/activate
```

# Creating a wrapper to accept audio streams
Quick Start for Python Demo

Go to the demo app folder, Run `python` in the command line. This will open an interactive python shell you can run the following code to create an object and listen for the wakeword

     import snowboydecoder
    
     def detected_callback():
       ....:     print "hotword detected"
      
    
     detector = snowboydecoder.HotwordDetector("resources/snowboy.umdl", sensitivity=0.5, audio_gain=1)
    
    detector.start(detected_callback)
    
Then speak "snowboy" into to your microphone to see whetheer Snowboy detects you. To use your personal model change `resources/snowboy.umdl` to your model path.

**TODO**: 

**Backend**: *Based off the snowboydecoder.HotwordDetector object we can build a backend service. Listen for audio stream over http on a port and then pass the audio stream data into the detector object. Check the audio object type snowboydecoder.HotwordDetector accepts. Then we need to convert the audio stream to that object type. Run this on a server so that it accepts an audio stream and sends back an http response.* 

**Frontend**: *Continously listen to the microphone of the user and whenever he speaks we need to send a request to the above backend with the payload as the audio stream and expect a response.*

