# FROM reg.aichallenge.ir/aic/base/infra/compiler:v4
FROM reg.aichallenge.ir/python:3.8

RUN apt update && apt install -y vim curl gettext
RUN apt-get update && \
    apt install -y vim curl gettext cmake unzip

COPY ./base_lib_req.txt ./
RUN pip install --upgrade pip
RUN pip install -r base_lib_req.txt -f https://download.pytorch.org/whl/torch_stable.html
# install code
WORKDIR /home
ADD ./requirements.txt ./requirements.txt
# ENV PIP_NO_CACHE_DIR 1
RUN pip install -r ./requirements.txt

ADD ./src ./src
ADD ./scripts ./scripts

RUN chmod +x scripts/compile.sh
RUN chmod +x src/compiler-psudo.sh


# make logging directory
RUN mkdir -p /var/log/compiler
WORKDIR /home/src
ENTRYPOINT ["python", "-u", "main.py"]
