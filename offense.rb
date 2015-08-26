require 'dxruby'
require_relative 'ev3/ev3'

RIGHT_MOTOR = "A"
LEFT_MOTOR = "D"
LEFT_ARM = "B"
RIGHT_ARM = "C"
DISTANCE_SENSOR = "1"
PORT = "COM3"
MOTOR_SPEED = 20
ARM_SPEED = 125

def sensor_read(brick)
  brick.get_sensor(DISTANCE_SENSOR, 0)
end

begin
  puts "starting..."
  font = Font.new(32)
  brick = EV3::Brick.new(EV3::Connections::Bluetooth.new(PORT))
  brick.connect
  puts "connected..."
  motors = [LEFT_MOTOR, RIGHT_MOTOR]
  arms = [LEFT_ARM, RIGHT_ARM]
  brick.reset(*motors)
  advance = true
  arm_flg = 0
  flg = 0

  Window.loop do
    break if Input.keyDown?( K_ESCAPE )
    if arm_flg == 0
      brick.reverse_polarity(*arms)
      arm_flg = 1
    end
    brick.start(ARM_SPEED, *arms)
    if (4...60) === sensor_read(brick) && advance
      brick.run_forward(*motors)
      brick.start(MOTOR_SPEED, *motors)
    elsif sensor_read(brick) < 10 || sensor_read(brick) >= 254
      if flg == 0
        brick.stop(false, *motors)
        sleep 0.2
        brick.reverse_polarity(*motors)
        advance = false
        flg = 1
      end
      brick.start(MOTOR_SPEED, *motors)
    elsif (60..100) === sensor_read(brick)
      brick.run_forward(*motors)
      brick.start(MOTOR_SPEED, *motors)
      if flg == 1
        brick.stop(false, *motors)
        sleep 0.2
        advance = true
        flg = 0
      end
    end
  end
rescue
  p $!
ensure
  puts "closing..."
  brick.stop(false, *motors)
  brick.stop(false, *arms)
  brick.run_forward(*arms)
  brick.clear_all
  brick.disconnect
  sleep 2
  puts "finished..."
end
