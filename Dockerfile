FROM cypress/included


RUN mkdir /app
WORKDIR /app

RUN  apt-get update && apt-get install -y \
    vim \
    gcc \
    g++ \
    cmake \
    gdb \ 
    strace \
    lsof \
    file \
    less \ 
    lldb
COPY . .
RUN Xvfb :99 & export DISPLAY=:99
EXPOSE 9229

CMD ["sh"]