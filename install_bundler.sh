#!/bin/bash

if [ "$RAILS_VERSION" == "4.2" ]
then
  gem uninstall -v ">= 2" -i $(rvm gemdir)@global -ax bundler || true
  gem install bundler -v "< 2"
else
  gem install bundler
fi
