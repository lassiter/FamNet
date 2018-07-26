FROM ruby:latest

RUN apt-get update && apt-get install -y nodejs

COPY . /var/www/app
WORKDIR /var/www/app

RUN bundle install

CMD rails server -p 3000 -b 0.0.0.0