## General
Rule. Split data processing logic from resource blocks
Rule. Use URI as resource identifier
Rule. Resource creation is always conditional and may be given to user

Rule. Generalize configurations that are reused in different resources e.g. sl, nsg, tags
Rule. Define default configurations e.g. tags

## Variables
Rule. Always map variables to local constants
Rule. Mark variables holding unique identifier with _fqn suffix

## Outputs
Rule. Always define outputs to make it possible to use code as a module

## Configuration
Rule. Use URI as identifier for resources' for_each
Rule. Use URI to encode resource logical location and display_name

## Data interchange
Rule. Store resource set in file or object to be available for other resources managed in other context (tf state)

## Data preparation
Rule. Prepare all attributes for resource out of resource block
Rule. Prepare data for resources as precise as possible.

Rule. Add compartment fqn attribute to all managed objects to be able to keep the resource in other place than encoded in the URI
Rule. Mark keys, and attributes conveying unique identifier with _fqn suffix
Rule. Resource location_fqn may be provided as compartment or logical location_fqn

Rule. Process data in several steps to make code as clear as possible
Rule. Rewrite all attributes to be available in next processing step
Rule. Optional attributes take null value; rewrite them with try()

Rule. Store fqn in resource's tag

Rule. Data processing guarantees completeness of data set processing
Rule. Use can(dirname(sl_fqn)) checks that data is encoded in a key. Use other data structure to provide data as attributes

## Resource 
Rule. Keep no data processing logic in resource block

## Debug
Rule. Keep output ready to debug resource creation
Rule. Keep intermediate attributes for debug purposes

## HCL hints
Rule. Constants computation order is not important in HCL

```
grep -rRule */*.tf | cut -f2 -d: | sed 's/TODO/#/' | sed 's|//|#|g' | sed 's/# #/#/' | cut -f2 -d'#'
```