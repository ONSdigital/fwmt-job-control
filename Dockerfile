FROM alpine:latest
RUN apk add build-base libxml2-dev libxslt-dev ruby ruby-dev
RUN gem install bundler --no-document

RUN mkdir -p /opt/fwmt-job-control
WORKDIR /opt/fwmt-job-control

COPY Gemfile .
RUN bundle install --without development

COPY data/ ./data
COPY lib/ ./lib
COPY public/ ./public
COPY views/ ./views
COPY app.rb .
COPY config.ru .

# Add values below before building i.e. ENV FWMT_DEVELOPMENT_URL https://...
ENV FWMT_DEVELOPMENT_URL
ENV FWMT_PREPRODUCTION_URL 
ENV FWMT_PRODUCTION_URL 
ENV FWMT_CENSUSTEST_URL 

EXPOSE 9292
CMD ["bundle", "exec", "puma", "-e", "production"]
