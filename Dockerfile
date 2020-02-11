FROM ruby:2

RUN useradd -ms $(which bash) runner
USER runner

ENV HOME=/home/runner
ENV LANG=C.UTF-8
RUN gem update bundler
ENV APP_HOME=$HOME/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY --chown=runner:runner . .
RUN bundle install
