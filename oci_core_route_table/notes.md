
# DRG route table

drg route 10.1.0.1/32 via /hub1/drg_central/att_spoke1
drg route 10.1.0.1/32 via ../att_spoke1
drg route 10.1.0.1/32 via att_spoke1

Note: DRG routing destination is always within the DRG, thus FQN addressing may be simplified to just a name of the attachment. When simplified, prefix will be taken from the DRG's FQN.

# VCN route tables

vcn route /spoke_GC2/vcn_test2 via LPG /spoke1/lpg_spoke2 
vcn route /spoke_GC2/vcn_test2 via LPG ../lpg_spoke2 
vcn route /spoke_GC2/vcn_test2 via LPG lpg_spoke2 

Note: VCN routing destination is always within the VCN, thus FQN addressing may be simplified to just a name of the gateway. When simplified, prefix will be taken from the VCN's FQN.
