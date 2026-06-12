class ApplicationMailer < ActionMailer::Base
  default from: "Time Tracker <no-reply@time-tracker.local>"
  layout "mailer"
end
