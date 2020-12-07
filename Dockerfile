ARG RVM_RUBY_VERSIONS="2.7.1"
# building from ruby image
FROM utexas-glib-it-docker-local.jfrog.io/rvm-stable:2.0.0
# install dependencies
RUN yum -y install nodejs mysql-devel
RUN dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y \
  && dnf install -y ImageMagick

# maintainer
LABEL maintainer "Squid Storm <LIT-Squid-Storm@austin.utexas.edu>"
# set user
USER ${RVM_USER}

# set variables
ENV RUBY=2.7.1
ENV RAILS=5.2.4

# set WORKDIR
WORKDIR /home/rvm

# Install blacklight and packages
COPY --chown=rvm:rvm src/template.rb /home/rvm/template.rb
RUN gem install --no-document rails -v ${RAILS}
RUN gem install --no-document mysql2 activerecord-mysql2-adapter sqlite3
RUN rails new . -m /home/rvm/template.rb
RUN bundle add rest-client
RUN bundle install

RUN rails g devise_invitable User
RUN rake db:migrate
RUN echo "" >> Gemfile && echo "gem 'mysql2'" >> Gemfile
RUN echo "" >> Gemfile && echo "gem 'devise_saml_authenticatable'" >> Gemfile

# remove directory under version control
RUN rm -rf /home/rvm/app
RUN rm -rf /home/rvm/config
RUN rm -rf /home/rvm/db
RUN rm -rf /home/rvm/lib
RUN rm -rf /home/rvm/public
RUN rm -rf /home/rvm/test

# copy app changes to container
COPY --chown=rvm:rvm src/spotlight /home/rvm
COPY --chown=rvm:rvm src/ca /home/rvm/ca
COPY --chown=rvm:rvm src/ssl /home/rvm/ssl

EXPOSE 4000
CMD bundle exec puma -C config/puma.rb
