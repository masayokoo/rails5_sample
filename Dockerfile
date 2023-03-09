FROM --platform=linux/x86_64 ruby:2.3.8-stretch

ENV RUBYOPT -EUTF-8
ENV LANG C.UTF-8
ENV PHANTOM_VERSION 2.1.1

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev fonts-migmix mysql-client libfreetype6 libfontconfig wget nginx supervisor apt-transport-https ca-certificates

# install node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install nodejs

# install yarn
RUN wget https://github.com/yarnpkg/yarn/releases/download/v1.9.4/yarn_1.9.4_all.deb
RUN dpkg -i yarn_1.9.4_all.deb

RUN rm -rf /var/lib/apt/lists/*

ENV BUNDLE_JOBS=4

RUN mkdir /app

WORKDIR /app

COPY Gemfile /app/Gemfile

COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

# コンテナ起動時に実行させるスクリプトを追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# CMD:コンテナ実行時、デフォルトで実行したいコマンド
# Rails サーバ起動
CMD ["rails", "server", "-b", "0.0.0.0"]
