# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012-2017, Sebastian Staudt

namespace :cache do

  task clear: :environment do
    Rails.cache.clear
  end

end
