# syntax=docker/dockerfile:1
FROM ruby:3.2.3
RUN apt-get update -qq && apt-get -y install mariadb-client

ADD config.ru Gemfile Gemfile.lock Rakefile /dolos/
WORKDIR /dolos
RUN bundle install && mkdir log

ADD app/ /dolos/app
ADD bin/ /dolos/bin
ADD config/ /dolos/config
ADD db/ /dolos/db
ADD lib/ /dolos/lib
ADD public/ /dolos/public
ADD test/ /dolos/test
ADD .env /dolos/.env
ADD .env.development /dolos/.env.development
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
