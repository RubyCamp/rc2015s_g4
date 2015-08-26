require 'dxruby'
require_relative 'ev3/ev3'

LEFT_MOTOR = "D"
RIGHT_MOTOR = "C"
PORT = "COM3"
MOTOR_SPEED = 30

begin
  puts "starting..."
  brick = EV3::Brick.new(EV3::Connections::Bluetooth.new(PORT))
  brick.connect
  puts "connected..."
  motors = [LEFT_MOTOR, RIGHT_MOTOR]
  brick.reset(*motors)

  Window.loop do
    break if Input.keyDown?( K_ESCAPE )
    brick.start(MOTOR_SPEED, *motors)
    sleep 0.3
    brick.stop(false, *motors)
    break
  end
rescue
  p $!
ensure
  puts "closing..."
  brick.stop(false, *motors)
  brick.clear_all
  brick.disconnect
  puts "finished..."
end
