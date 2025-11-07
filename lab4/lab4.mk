#=========================================================================
# lab4
#=========================================================================

lab4_srcs = \

lab4_partA_tests = \

#lab4_partB_tests = \
#  SPI2300_RTL-test.v \
#  tinyrv1-test.v \

lab4_tests = \
  $(lab4_partA_tests) \

#  $(lab4_partB_tests) \

lab4_sims = \
  proc-isa-sim.v \

$(eval $(call check_part,lab4_partA))
#$(eval $(call check_part,lab4_partB))
$(eval $(call check_part,lab4))

