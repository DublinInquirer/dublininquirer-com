# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

# Rails.application.config.content_security_policy do |policy|
#   policy.default_src :self, :https
#   policy.font_src    :self, :https, :data, "http://localhost:5000"
#   policy.img_src     :self, :https, :data
#   policy.object_src  :none
#   policy.frame_src   "https://js.stripe.com"
#   policy.script_src  :self, :https, :unsafe_inline, :unsafe_eval, "https://js.stripe.com"
#   policy.style_src   :self, :https, :unsafe_inline, "http://localhost:5000"

#   if Rails.env.development?
#     policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035", "http://localhost:5000", "https://js.stripe.com"
#   else
#     policy.connect_src :self, :https, "https://js.stripe.com"
#   end
# end
