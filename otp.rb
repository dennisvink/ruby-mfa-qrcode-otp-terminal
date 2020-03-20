#!/usr/bin/env ruby

require "rotp"
require "tty-prompt"
require "rqrcode"

prompt = TTY::Prompt.new

mfa_username = prompt.ask("Username", default: "myusername")

mfa_secret = prompt.ask("MFA Secret", default: "7QRES73S6NNGRNMLYPPXHKR4U7T3UJUGCNWHUJQZPB7JZ7SPSCKHHFLUW4ROMYA3") do |q|
  q.validate(/^([a-zA-Z0-9]*)$/, "Invalid secret")
end

mfa_label = prompt.ask("Label", default: "My Acccount")

topt = ROTP::TOTP.new(mfa_secret, issuer: mfa_label)

current_token = topt.now
next_token = topt.at(Time.now.to_i + 60)

qr_string = topt.provisioning_uri(mfa_username)

qrcode = RQRCode::QRCode.new(qr_string)
puts qrcode.as_ansi(
  light: "\033[47m", dark: "\033[40m",
  fill_character: "  ",
  quiet_zone_size: 4
)

puts "MFA Code (1): #{current_token}"
puts "MFA Code (2): #{next_token}"
