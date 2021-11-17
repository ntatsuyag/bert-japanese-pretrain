# ベースイメージ
FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04

# installしたいTensorFlowのversion
ARG TF_ver=2.4.1
# userの設定とデフォルトの設定
ARG USERNAME=dockeruser && GROUPNAME=dockeruser && UID=1057 && GID=1000
RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/bash -u $UID -g $GID $USERNAME
LABEL maintainer="ntatsuya"

WORKDIR /home/$USERNAME/
# PATHを通す
ENV PATH /home/dockeruser/.local/bin:$PATH

COPY ./requirements.txt ./

ENV PYTHONIOENCODING utf-8
RUN printenv

EXPOSE 8888
RUN apt-get update && apt-get install -y --no-install-recommends wget build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev libgdbm-dev libbz2-dev liblzma-dev zlib1g-dev uuid-dev libffi-dev libdb-dev git vim

# python install
RUN cd / \
&& wget --no-check-certificate https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tgz \
&& tar -xf Python-3.8.9.tgz \
&& cd Python-3.8.9 \
&& ./configure --enable-optimizations \
&& make \
&& make install \
&& rm ../Python-3.8.9.tgz

# mecab install
RUN apt-get install -y mecab mecab-ipadic mecab-ipadic-utf8 libmecab-dev swig libmecab2
RUN apt-get autoremove -y

# ユーザーの切り替え
USER $USERNAME

# transformersのinstallでRust関連のエラーが出たら以下
# RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
# ENV PATH=/root/.cargo/bin:$PATH

#python package install
RUN python3 -m pip install --user --upgrade pip && python3 -m pip install --user --no-cache-dir jupyterlab tensorflow==$TF_ver tensorboard_plugin_profile mecab-python3==0.996.5 unidic-lite ipywidgets transformers==4.3.2 fuzzywuzzy
RUN python3 -m pip install --user --no-cache-dir -r ./requirements.txt
RUN cd /home/$USERNAME/

CMD /bin/bash