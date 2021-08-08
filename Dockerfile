FROM brainlife/freesurfer-stats:1.2

RUN pip3 install --upgrade pip
RUN pip3 install neuropythy

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN ldconfig && mkdir -p /N/u /N/home /N/dc2 /N/soft


