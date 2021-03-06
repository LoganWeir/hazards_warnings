FROM ruby:2.3.0
MAINTAINER Logan Weir "loganweir@gmail.com"
ENV REFRESHED_AT 12/7/2016

ENV APP_HOME /harvist
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install

ADD . $APP_HOME

CMD ["./weather_warning_generator.sh", "bounded_public_zones.geojson"]