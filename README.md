## General
* Split data processing logic from resource blocks
* Use URI as resource identifier
* Resource creation is always conditional and may be given to user

* Generalize configurations that are reused in different resources e.g. sl, nsg, tags
* Define default configurations e.g. tags

## Variables
* Always map variables to local constants

* Mark variables holding unique identifier with _fqn suffix

## Outputs
* Always define outputs to make it possible to use code as a module

## Configuration
* Use URI as identifier for resources' for_each
* Use URI to encode resource logical location and display_name

## Data interchange
* Store resource set in file or object to be available for other resources managed in other context (tf state)

## Data preparation
* Prepare all attributes for resource out of resource block
* Prepare data for resources as precise as possible.

* Add compartment fqn attribute to all managed objects to be able to keep the resource in other place than encoded in the URI
* Mark keys, and attributes conveying unique identifier with _fqn suffix
* Resource location_fqn may be provided as compartment or logical location_fqn

* Process data in several steps to make code as clear as possible
* Rewrite all attributes to be available in next processing step
* Optional attributes take null value; rewrite them with try()

* Store fqn in resource's tag

* Data processing guarantees completeness of data set processing
* Use can(dirname(sl_fqn)) checks that data is encoded in a key. Use other data structure to provide data as attributes

## Resource 
* Keep no data processing logic in resource block

## Debug
* Keep output ready to debug resource creation
* Keep intermediate attributes for debug purposes

## HCL hints
* Constants computation order is not important in HCL

