FROM ruby:2.6.3

#apt-keyとdevconfのエラー対策
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV DEBCONF_NOWARNINGS=yes

# node.jsと必要なライブラリのインストトール
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client \
  curl apt-transport-https wget

# yarnのインストール
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN set -x && apt-get update -y -qq && apt-get install -yq nodejs yarn

#aptキャッシュの削除
RUN rm -rf /var/lib/apt/lists/*

# ディレクトリ・ファイルの作成
RUN mkdir /calappdocker
WORKDIR /calappdocker
COPY Gemfile /calappdocker/Gemfile
COPY Gemfile.lock /calappdocker/Gemfile.lock

# gem(Rails6)のインストール
RUN bundle install
COPY . /calappdocker

RUN bundle exec rails webpacker:compile

# コンテナ起動時に毎回実行するスクリプトを追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 5050

# rails起動コマンド
CMD ["rails", "server", "-b", "0.0.0.0"]
