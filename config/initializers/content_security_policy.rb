# You need to allow webpack-dev-server host as allowed origin for connect-src.
# This can be done in Rails 5.2+ for development environment in the CSP initializer
# config/initializers/content_security_policy.rb with a snippet like this:
# policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?