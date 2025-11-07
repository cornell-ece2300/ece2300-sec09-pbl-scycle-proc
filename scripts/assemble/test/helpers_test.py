"""
==========================================================================
helpers_test.py
==========================================================================
Test cases for helper functions

Author : Shunning Jiang
  Date : Nov 30, 2019
"""

from scripts.assemble.Bits import Bits
from scripts.assemble.helpers import *

def test_concat():
  x = concat( Bits(128,0x1234567890abcdef1234567890abcdef),
              Bits(252,0xfffffffff22222222222222222444441234567890abcdef1234567890abcdef) )
  assert x.nbits == 380
  assert x == Bits(380,0x1234567890abcdef1234567890abcdeffffffffff22222222222222222444441234567890abcdef1234567890abcdef)

def test_zext():
  assert zext( Bits(8,0xe), 24 ) == Bits(24,0xe)

def test_sext():
  assert zext( Bits(8,0xe), 24 ) == Bits(24,0xe)

def test_clog2():
  assert clog2(7) == 3
  assert clog2(8) == 3
  assert clog2(9) == 4

def test_reduce_and():
  for i in range(255):
    assert not reduce_and( Bits(8,i) )
  assert reduce_and( Bits(8,255) )
  assert reduce_and( Bits(512,(2**512)-1) )

def test_reduce_or():
  for i in range(1, 256):
    assert reduce_or(i)
  assert not reduce_or( Bits(8,0) )
  assert reduce_or( Bits(512,(2**512)-1) )

def test_reduce_xor():
  assert reduce_xor( Bits(8,0b10101011) ) == 1
  assert reduce_xor( Bits(8,0b10101010) ) == 0
