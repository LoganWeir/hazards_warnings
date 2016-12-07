FROM ruby:2.3.0
MAINTAINER Logan Weir "loganweir@gmail.com"
ENV REFRESHED_AT 12/6/2016

ENV APP_HOME /harvist
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME

RUN gem install bundler
RUN bundle install

CMD ["./weather_warning_generator.sh", "bounded_public_zones.geojson"]