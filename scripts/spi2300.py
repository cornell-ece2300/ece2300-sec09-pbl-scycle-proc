# File for running through SPI code to the processor

from pyftdi.spi import *
from pymtl3 import *


memory = [
  (0x00, 0x00200093),
  (0x04, 0x00208113),
  (0x08, 0x7f000193),
  (0x0c, 0x0021a023),
  (0x10, 0x0000006f),
]


def init_controller(freq: int) -> SpiPort:
  spi = SpiController()
  spi.configure('ftdi://ftdi:232h/1')
  return spi.get_port(cs=0, freq=freq, mode=0)


def spi_write(controller: SpiPort, src_msg: int) -> int:
  assert isinstance(src_msg, int), "src_msg is not an int."
  assert src_msg < (1 << 42), f"src_msg={src_msg} is not less than {(1 << 42)}"

  msg = src_msg
  msg_bytes = []

  while msg > 0:
    msg_bytes.append(msg & 0xFF)
    msg >>= 8

  while len(msg_bytes) < 6:
    msg_bytes.append(0)
  
  msg_bytes.reverse()

  write_buf = bytes(msg_bytes)
  return controller.write(write_buf)
