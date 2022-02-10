FROM ubuntu:16.04

RUN apt update && apt --yes --force-yes install wget unzip build-essential python python-dev virtualenv portaudio19-dev
RUN wget https://github.com/Keshavnemeli/snowboy-test/archive/refs/heads/main.zip && unzip main.zip && mv snowboy-test-main snowboyMaster

RUN cd snowboyMaster/ && \
    virtualenv -p python2 venv/snowboy && \
    . venv/snowboy/bin/activate && \
    cd examples/Python && \
    pip install -r requirements.txt

RUN apt -y remove wget unzip build-essential portaudio19-dev && apt -y autoremove && apt clean && rm -rf /var/lib/apt/lists/*

CMD cd snowboyMaster/ && \
    . venv/snowboy/bin/activate && \
    cd examples/Python && \
    python generate_pmdl.py -r1=model/record1.wav -r2=model/record2.wav -r3=model/record3.wav -lang=en -n=model/hotword.pmdl
