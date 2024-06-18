# Instance image file
Image ids should be registered using variable.

# Configuration
Configuration as ocids or images may be loaded from bucket

# Encryption of files stored in bucket
Encryption is not available in terraform. Bucket should be configured with access for proper users via iam policies. Object storage iam policies allow to control access to folders.

# Created objects are saved in file
Having created objects in a file adds little complexity, but eliminates to scan whole system using data sources on terraform activity start. Each resource which may be required in the future should be saved to be available using:

oci.cmp["/spoke1/cmp_data]
oci.vcn["/xxx/vcn_data]
oci.sl["/spoke1/vcn_data/sl_db]
etc.


# Object location is encoded in fqn

1. URI contains location

location_fqn    = dirname(object_fqn) 

2. Location is converted to compartment using locations map

compartment_fqn = local.locations[location_fqn]

3. compartment_fqn is converted to id using (a) ocids map, (b) map with created objects.




